#!/bin/ksh
## Script for the databases restore & recover for DR 2011
## Author : Mariano Quidiello
## Date : July 19th 2011 - Created
##
## Modifications
##
## Aug 15th 2011 - M. Quidiello :
##	- Finished all restore/recover operations
##	- Added flag for starting in a determined step
## Aug 16th 2011 - M. Quidiello :
##	- Added intelligence to choose from which step to start according to the current instance status
##	- Added Check function, to be executed at the end ( or force it through the STEP flag
## Aug 17th 2011 - M. Quidiello :
##	- Added Parallelism for restore
##	- Added functions to test startup/mount/open before triggering restores
## Aug 18th 2011 - M. Quidiello :
##	- Added Parallelism for recover
## Aug 22nd 2011 - M. Quidiello :
##	- Added sending emails after finishing
##	- Revised logging. It now creates a full log as well (the one that sends through email)
## Features to add:	
## 			3- Argument Check for the Steps flag
## 			4- Help
## 			5- Newnames for restoring ASM to FS

## Global Variables
PATH=/usr/local/bin:$PATH:.
NLS_DATE_FORMAT='YYYY-MON-DD HH24:MI:SS'
#SCRIPTDIR="`dirname $0`"
SCRIPTDIR="`pwd`"
RUNTIME=`date '+%Y%m%d%H%M%S'`
WORKDIR_RMAN="${SCRIPTDIR}/rman"
LOGDIR="${SCRIPTDIR}/log"

unset ORACLE_SID ORACLE_HOME DBID TDPO

## Functions

getInstanceStatusSqlplus()
{
	sqlplus -s "/ as sysdba" <<-"SQL" | grep '^STATUS:' | head -1
		set pages 0
		set feed off
		WHENEVER OSERROR EXIT FAILURE
		WHENEVER SQLERROR EXIT FAILURE
		select 'STATUS:'||status
		from v$instance;
		exit
	SQL
	INSTANCE_STATUS_SQL_RC="$?"

	if [ "${INSTANCE_STATUS_SQL_RC}" -ne 0 ]
	then
		echo STATUS:ERROR
	fi
	return "${INSTANCE_STATUS_SQL_RC}"
}

getInstanceStatus()
{
	INSTANCE_PROCESS=`ps -ef | grep ora_pmon | grep -v grep | awk '{ print $NF }' | cut -f3 -d_ | grep "${ORACLE_SID}"`

	if [ "${INSTANCE_PROCESS}" != "${ORACLE_SID}" ]
	then
		echo No pmon process for the ${ORACLE_SID}, Instance not started.
		INSTANCE_STATUS="NOT_STARTED"
	else
		INSTANCE_STATUS=`getInstanceStatusSqlplus|cut -f2 -d:`
		INSTANCE_STATUS_RC=$?
	fi
	
	export INSTANCE_STATUS
	return "${INSTANCE_STATUS_RC}"
}

getDBName()
{
	sqlplus -s "/ as sysdba" <<-"SQL" | grep -v '^$' | head -1
		set pages 0
		set feed off
		WHENEVER OSERROR EXIT FAILURE
		WHENEVER SQLERROR EXIT FAILURE
		select VALUE
		from v$parameter
		where name='db_name';
		exit
	SQL
	return "$?"
}

testFullStartup()
{
	echo trying to open the Database ${ORACLE_SID}...
	sqlplus -s "/ as sysdba" <<-"SQL"
		set pages 0
		set feed off
		WHENEVER OSERROR EXIT FAILURE
		WHENEVER SQLERROR EXIT FAILURE
		startup
		exit
	SQL
	return "$?"
}

testOpen()
{
	echo trying to open the Database ${ORACLE_SID}...
	sqlplus -s "/ as sysdba" <<-"SQL"
		set pages 0
		set feed off
		WHENEVER OSERROR EXIT FAILURE
		WHENEVER SQLERROR EXIT FAILURE
		alter database open;
		exit
	SQL
	return "$?"
}

testMount()
{
	echo trying to mount Instance ${ORACLE_SID}...
	sqlplus -s "/ as sysdba" <<-"SQL"
		set pages 0
		set feed off
		WHENEVER OSERROR EXIT FAILURE
		WHENEVER SQLERROR EXIT FAILURE
		alter database mount;
		exit
	SQL
	return "$?"
}

testNomount()
{
	sqlplus -s "/ as sysdba" <<-"SQL"
		set pages 0
		set feed off
		WHENEVER OSERROR EXIT FAILURE
		WHENEVER SQLERROR EXIT FAILURE
		startup nomount
		exit
	SQL
	return "$?"
}


setEnvironment()
{
	ORAENV_ASK=NO
	export ORACLE_SID
	. oraenv
	if [ $? -ne 0 ]
	then
		echo "Error setting the environment for database ${ORACLE_SID}." >&2
		return 1
	fi
	return 0
}

testTDPOenv()
{
	if [ ! -r "${TDPO}" ]
	then
		echo "Error. Cannot access TDPO file ${TDPO}" >&2
		return 1
	fi
	TDPODIR=`dirname ${TDPO}`

	mkfifo ${LOGDIR}/testTDPO_${ORACLE_SID}_${RUNTIME}.log.pipe 
	if [ $? -ne 0 ]
	then
		echo Error creating log pipe ${LOGDIR}/testTDPO_${ORACLE_SID}_${RUNTIME}.log.pipe
		return 1
	else
		tee ${LOGDIR}/testTDPO_${ORACLE_SID}_${RUNTIME}.log < ${LOGDIR}/testTDPO_${ORACLE_SID}_${RUNTIME}.log.pipe &
		if [ $? -ne 0 ]
		then
			echo Error creating log ${LOGDIR}/testTDPO_${ORACLE_SID}_${RUNTIME}.log
			return 1
		else
			echo "${TDPODIR}/tdpoconf showenv -TDPO_OPTFILE=${TDPO} > ${LOGDIR}/testTDPO_${ORACLE_SID}_${RUNTIME}.log.pipe 2>&1"
			${TDPODIR}/tdpoconf showenv -TDPO_OPTFILE=${TDPO} > ${LOGDIR}/testTDPO_${ORACLE_SID}_${RUNTIME}.log.pipe 2>&1
			TDPO_TEST_RC=$?
			rm -f ${LOGDIR}/testTDPO_${ORACLE_SID}_${RUNTIME}.log.pipe
		fi
	fi
	return $TDPO_TEST_RC
}

createRestoreSpfileScript()
{
	cat <<-CAT >> ${WORKDIR_RMAN}/restoreSpfile_${ORACLE_SID}_${RUNTIME}.rman
		set dbid ${DBID};
		startup force nomount;
		run
		{
			allocate channel t1 type ${CHANNEL_TYPE:-DISK} ${TDPO:+parms 'ENV=(TDPO_OPTFILE=${TDPO})'} maxopenfiles 8;
			RESTORE SPFILE TO '${ORACLE_HOME}/dbs/spfile${ORACLE_SID}.ora' FROM ${PIECE:-AUTOBACKUP MAXDAYS 15} ${UNTIL_CLAUSE:+until} ${UNTIL_CLAUSE};
			startup force nomount
		}
		exit
	CAT
	return $?
}

restoreSpfile()
{
	createRestoreSpfileScript ${DBID} ${TDPO}
	if [ $? -ne 0 ]
	then
		echo Error creating script for SPFILE restore
		return 1
	else
		mkfifo ${LOGDIR}/restoreSpfile_${ORACLE_SID}_${RUNTIME}.log.pipe 
		if [ $? -ne 0 ]
		then
			echo Error creating log pipe ${LOGDIR}/restoreSpfile_${ORACLE_SID}_${RUNTIME}.log.pipe
			return 1
		else
			tee ${LOGDIR}/restoreSpfile_${ORACLE_SID}_${RUNTIME}.log < ${LOGDIR}/restoreSpfile_${ORACLE_SID}_${RUNTIME}.log.pipe &
			if [ $? -ne 0 ]
			then
				echo Error creating log ${LOGDIR}/restoreSpfile_${ORACLE_SID}_${RUNTIME}.log
				return 1
			else
				rman target / @${WORKDIR_RMAN}/restoreSpfile_${ORACLE_SID}_${RUNTIME}.rman > ${LOGDIR}/restoreSpfile_${ORACLE_SID}_${RUNTIME}.log.pipe 2>&1
				SPFILE_RESTORE_RC=$?
				rm -f ${LOGDIR}/restoreSpfile_${ORACLE_SID}_${RUNTIME}.log.pipe
			fi
		fi
	fi
	return $SPFILE_RESTORE_RC
}

createRestoreControlfileScript()
{
	cat <<-CAT >> ${WORKDIR_RMAN}/restoreControlfile_${ORACLE_SID}_${RUNTIME}.rman
		set dbid ${DBID};
		run
		{
			allocate channel t1 type ${CHANNEL_TYPE:-DISK} ${TDPO:+parms 'ENV=(TDPO_OPTFILE=${TDPO})'} maxopenfiles 8;
			RESTORE controlfile FROM ${PIECE:-AUTOBACKUP MAXDAYS 15} ${UNTIL_CLAUSE:+until} ${UNTIL_CLAUSE};
			alter database mount;
		}
		exit
	CAT
	return $?
}

restoreControlfile()
{
	createRestoreControlfileScript ${DBID} ${TDPO}
	if [ $? -ne 0 ]
	then
		echo Error creating script for Controlfile restore
		return 1
	else
		mkfifo ${LOGDIR}/restoreControlfile_${ORACLE_SID}_${RUNTIME}.log.pipe 
		if [ $? -ne 0 ]
		then
			echo Error creating log pipe ${LOGDIR}/restoreControlfile_${ORACLE_SID}_${RUNTIME}.log.pipe
			return 1
		else
			tee ${LOGDIR}/restoreControlfile_${ORACLE_SID}_${RUNTIME}.log < ${LOGDIR}/restoreControlfile_${ORACLE_SID}_${RUNTIME}.log.pipe &
			if [ $? -ne 0 ]
			then
				echo Error creating log ${LOGDIR}/restoreControlfile_${ORACLE_SID}_${RUNTIME}.log
				return 1
			else
				rman target / @${WORKDIR_RMAN}/restoreControlfile_${ORACLE_SID}_${RUNTIME}.rman > ${LOGDIR}/restoreControlfile_${ORACLE_SID}_${RUNTIME}.log.pipe 2>&1
				CONTROLFILE_RESTORE_RC=$?
				rm -f ${LOGDIR}/restoreControlfile_${ORACLE_SID}_${RUNTIME}.log.pipe
			fi
		fi
	fi
	return $CONTROLFILE_RESTORE_RC
}

createRestoreDBScript()
{

	cat <<-CAT > ${WORKDIR_RMAN}/restoreDB_${ORACLE_SID}_${RUNTIME}.rman
		run
		{
	CAT

	PARALLELISM_RESTORE="${PARALLELISM:-1}"
	while [ "${PARALLELISM_RESTORE}" -ge 1 ]
	do
		CHANNEL="$((${CHANNEL:=0}+1))"
		cat <<-CAT >> ${WORKDIR_RMAN}/restoreDB_${ORACLE_SID}_${RUNTIME}.rman
			allocate channel c${CHANNEL} type ${CHANNEL_TYPE:-DISK} ${TDPO:+parms 'ENV=(TDPO_OPTFILE=${TDPO})'} maxopenfiles 8;
		CAT
		PARALLELISM_RESTORE="$((${PARALLELISM_RESTORE}-1))"
	done

	cat <<-CAT >> ${WORKDIR_RMAN}/restoreDB_${ORACLE_SID}_${RUNTIME}.rman
		RESTORE database ${UNTIL_CLAUSE:+until} ${UNTIL_CLAUSE};
		}
	CAT

	return $?
}

restoreDB()
{
	createRestoreDBScript ${DBID} ${TDPO}
	if [ $? -ne 0 ]
	then
		echo Error creating script for DB restore
		return 1
	else
		mkfifo ${LOGDIR}/restoreDB_${ORACLE_SID}_${RUNTIME}.log.pipe 
		if [ $? -ne 0 ]
		then
			echo Error creating log pipe ${LOGDIR}/restoreDB_${ORACLE_SID}_${RUNTIME}.log.pipe
			return 1
		else
			tee ${LOGDIR}/restoreDB_${ORACLE_SID}_${RUNTIME}.log < ${LOGDIR}/restoreDB_${ORACLE_SID}_${RUNTIME}.log.pipe &
			if [ $? -ne 0 ]
			then
				echo Error creating log ${LOGDIR}/restoreDB_${ORACLE_SID}_${RUNTIME}.log
				return 1
			else
				rman target / @${WORKDIR_RMAN}/restoreDB_${ORACLE_SID}_${RUNTIME}.rman > ${LOGDIR}/restoreDB_${ORACLE_SID}_${RUNTIME}.log.pipe 2>&1
				DB_RESTORE_RC=$?
				rm -f ${LOGDIR}/restoreDB_${ORACLE_SID}_${RUNTIME}.log.pipe
			fi
		fi
	fi
	return $DB_RESTORE_RC
}

getArchivelogMode()
{
	sqlplus -s "/ as sysdba" <<-"SQL" | grep -v '^$' | head -1
		set pages 0
		set feed off
		WHENEVER OSERROR EXIT FAILURE
		WHENEVER SQLERROR EXIT FAILURE
		select log_mode
		from v$database;
		exit
	SQL
	return $?
}

createRecoverDBScript()
{
	if [ "${LOGMODE}" = "ARCHIVELOG" ]
	then
		cat <<-CAT > ${WORKDIR_RMAN}/recoverDB_${ORACLE_SID}_${RUNTIME}.rman
			run
			{
		CAT

		PARALLELISM_RECOVER="${PARALLELISM:-1}"
		while [ "${PARALLELISM_RECOVER}" -ge 1 ]
		do
			CHANNEL="$((${CHANNEL:=0}+1))"
			cat <<-CAT >> ${WORKDIR_RMAN}/recoverDB_${ORACLE_SID}_${RUNTIME}.rman
				allocate channel c${CHANNEL} type ${CHANNEL_TYPE:-DISK} ${TDPO:+parms 'ENV=(TDPO_OPTFILE=${TDPO})'} maxopenfiles 8;
			CAT
			PARALLELISM_RECOVER="$((${PARALLELISM_RECOVER}-1))"
		done

		cat <<-CAT >> ${WORKDIR_RMAN}/recoverDB_${ORACLE_SID}_${RUNTIME}.rman
			recover database ${UNTIL_CLAUSE:+until} ${UNTIL_CLAUSE};
			alter database open resetlogs;
			}
		CAT
		CREATE_RECOVER_SCRIPT_RC=$?
	else
		if [ "${LOGMODE}" = "NOARCHIVELOG" ]
		then
			cat <<-CAT >> ${WORKDIR_RMAN}/recoverDB_${ORACLE_SID}_${RUNTIME}.rman
				run
				{
					alter database open resetlogs;
				}
				exit
			CAT
			CREATE_RECOVER_SCRIPT_RC=$?
		else
			echo "BAD Archive Log mode obtained ( ${LOGMODE} )" >&2
			CREATE_RECOVER_SCRIPT_RC=1
		fi
	fi
	return "${CREATE_RECOVER_SCRIPT_RC}"
}

recoverDB()
{
	LOGMODE=`getArchivelogMode`
	if [ $? -ne 0 ]
	then
		echo Error Obtaining Archive Log mode >&2
		return 1
	else
		export LOGMODE
	fi

	createRecoverDBScript ${DBID} ${TDPO}
	if [ $? -ne 0 ]
	then
		echo Error creating script for DB restore
		return 1
	else
		mkfifo ${LOGDIR}/recoverDB_${ORACLE_SID}_${RUNTIME}.log.pipe 
		if [ $? -ne 0 ]
		then
			echo Error creating log pipe ${LOGDIR}/recoverDB_${ORACLE_SID}_${RUNTIME}.log.pipe
			return 1
		else
			tee ${LOGDIR}/recoverDB_${ORACLE_SID}_${RUNTIME}.log < ${LOGDIR}/recoverDB_${ORACLE_SID}_${RUNTIME}.log.pipe &
			if [ $? -ne 0 ]
			then
				echo Error creating log ${LOGDIR}/recoverDB_${ORACLE_SID}_${RUNTIME}.log
				return 1
			else
				rman target / @${WORKDIR_RMAN}/recoverDB_${ORACLE_SID}_${RUNTIME}.rman > ${LOGDIR}/recoverDB_${ORACLE_SID}_${RUNTIME}.log.pipe 2>&1
				DB_RECOVER_RC=$?
				rm -f ${LOGDIR}/recoverDB_${ORACLE_SID}_${RUNTIME}.log.pipe
			fi
		fi
	fi
	return "${DB_RECOVER_RC}"
}

checkDB()
{
	sqlplus -s "/ as sysdba" <<-"SQL"
		WHENEVER OSERROR EXIT FAILURE
		WHENEVER SQLERROR EXIT FAILURE
		set pages 200
		set lines 200
		set feed off
		col file_name for a70
		col error for a90
		col host_name for a40
		col RESETLOGS_CHANGE# for 9999999999999999999999999999999
		col CHANGE# for 9999999999999999999999999999999
		alter session set nls_date_format='YYYY-MON-DD HH24:MI:SS';
		select name,log_mode,OPEN_MODE,DATABASE_ROLE,RESETLOGS_TIME,RESETLOGS_CHANGE#
		from v$database;
		select instance_name,HOST_NAME,status,LOGINS,STARTUP_TIME
		from v$instance;
		select file#,change#,ONLINE_STATUS,error,time
		from v$recover_file;
		select file_name,tablespace_name,status,bytes/1024/1024 MB
		from dba_data_files
		order by status,tablespace_name,file_id;
		select file_name,tablespace_name,status,bytes/1024/1024 MB
		from dba_temp_files
		order by status,tablespace_name,file_id;
		exit
	SQL
	CHECK_DB_RC="$?"

	return "${CHECK_DB_RC}"
}

showDBstatus()
{
	echo 0

}

## Main
while getopts ":d:(database)i:(dbid):m:(mail)p:(bkppiece)P:(parallelism)u:(until)s:(step):T:" OPTION
do
	case $OPTION in
		d	) if [ -z "${ORACLE_SID}" ]
				then
					ORACLE_SID="${OPTARG}"
					echo $ORACLE_SID
				else
					echo "Error. Instance already set to ${ORACLE_SID}. Only one can be set." >&2
					return 1
				fi
				export ORACLE_SID;;
		i	) if [ -z "${DBID}" ]
				then
					DBID="${OPTARG}"
				else
					echo "Error. DBID already set to ${DBID}. Only one can be set." >&2
					return 1
				fi
				export DBID;;
		T	) if [ -z "${TDPO}" ]
				then
					TDPO="${OPTARG}"
					CHANNEL_TYPE="SBT_TAPE"
				else
					echo "Error. TDPO already set to ${TDPO}. Only one can be set." >&2
					return 1
				fi
				export CHANNEL_TYPE
				export TDPO;;
		u	) if [ -z "${UNTIL_CLAUSE}" ]
				then
					UNTIL_CLAUSE="${OPTARG}"
				else
					echo "Error. UNTIL_CLAUSE already set to ${UNTIL_CLAUSE}. Can be set only once." >&2
					return 1
				fi
				export UNTIL_CLAUSE;;
		p	) if [ -z "${PIECE}" ]
				then
					PIECE="'${OPTARG}'"
				else
					echo "Error. Piece already set to ${PIECE}. Can be set only once." >&2
					return 1
				fi
				export PIECE;;
		P	) if [ -z "${PARALLELISM}" ]
				then
					PARALLELISM="${OPTARG}"
					if [[ "${PARALLELISM}" != +([0-9]) ]]
					then
						echo "Especified parallelism ${PARALLELISM} is not an integer." >&2
						return 1
					fi
				else
					echo "Error. Parallelism already set to ${PARALLELISM}. Can be set only once." >&2
					return 1
				fi
				export PARALLELISM;;
		m	) if [ -z ${MAILLIST:-} ]
				then
					MAILLIST="${OPTARG}"
				else
					MAILLIST="${MAILLIST},${OPTARG}"
				fi
				export MAILLIST;;
		s	) if [ -z ${STEP:-} ]
				then
					STEP="`${OPTARG}| tr '[a-z]' '[A-Z]'`"
				else
					echo "Error. STEP already set to ${STEP}. Only one can be set." >&2
					return 1
				fi
				export STEP;;
		\?	) echo "Wrong usage. -d for entering the databases and -i for the DBID. \nOptionally -m for the emails" >&2
			  return 1
	esac
done

if [ -z "${ORACLE_SID}" ]
then
	echo "Error. Database must be one of the arguments. Use -d flag." >&2
	return 1
fi

mkfifo ${LOGDIR}/full_${ORACLE_SID}_${RUNTIME}.log.pipe
if [ $? -ne 0 ]
then
	echo Error creating log pipe ${LOGDIR}/full_${ORACLE_SID}_${RUNTIME}.log.pipe
	return 1
else
	tee ${LOGDIR}/full_${ORACLE_SID}_${RUNTIME}.log < ${LOGDIR}/full_${ORACLE_SID}_${RUNTIME}.log.pipe &
fi

## Subshell for keeping the full log
(
setEnvironment
if [ "$?" -ne 0 ]
then
	echo "Error setting the Environment." >&2
	exit 1
fi
if [ -n "${TDPO}" ]
then
	testTDPOenv
	if [ "$?" -ne 0 ]
	then
		echo "Error with the TDPO." >&2
		exit 1
	fi
fi

#script chooses the step in which to start according to the status of the instance
echo Obtaining instance Status
getInstanceStatus
if [ "$?" -ne 0 ]
then
	echo "Error getting instance status. Please check manually." >&2
	echo "Status for ${ORACLE_SID} is ${INSTANCE_STATUS}." >&2
	exit 1
else
	echo Instance Status is "${INSTANCE_STATUS:=ERROR}"
fi

case "${INSTANCE_STATUS:-ERROR}" in
		ERROR )		echo "Error getting instance status. Please check manually. You may need to shut it down with abort option." >&2 
				exit 1;;
                NOT_STARTED )	testFullStartup
				if [ "$?" -ne 0 ]
				then
					getInstanceStatus
					if [ "$?" -ne 0 ]
					then
						echo "Error getting instance status. Please check manually." >&2
						echo "Status for ${ORACLE_SID} is ${INSTANCE_STATUS}." >&2
						exit 1
					else
						echo Instance Status is "${INSTANCE_STATUS:=ERROR}"
						case "${INSTANCE_STATUS:-ERROR}" in
							ERROR )	echo "Error getting instance status. Please check manually. You may need to shut it down with abort option." >&2
								exit 1;;
							NOT_STARTED )	STEP="${STEP:-FULL}";;
							STARTED )	STEP="${STEP:-CONTROLFILE}";;
							MOUNTED )	STEP="${STEP:-RESTORE}";;
							OPEN )		STEP="CHECK";;
							* )		echo "Error getting instance status. Please check manually. You may need to shut it down with abort option." >&2
									exit 1;;
						esac
						export STEP
						break
					fi
				else
					echo Database ${ORACLE_SID} opened successfully.
					STEP="CHECK"
				fi
				export STEP;;
		STARTED )	DB_NAME=`getDBName`
				if [ ${DB_NAME} = "DUMMY" ]
				then
					STEP="${STEP:-SPFILE}"
				else
					testMount
					if [ "$?" -ne 0 ]
					then
						STEP="${STEP:-CONTROLFILE}"
						export STEP
						break
					else
						echo Instance ${ORACLE_SID} mounted successfully.
						STEP="RESTORE"
					fi
				fi
				export STEP;&
		MOUNTED )	testOpen
				if [ "$?" -ne 0 ]
				then
					STEP="${STEP:-RESTORE}"
					export STEP
					break
				else
					echo Database ${ORACLE_SID} opened successfully. Skipping to checks...
					STEP="CHECK"
				fi
				export STEP;&
		OPEN )		STEP="${STEP:-CHECK}"
				export STEP;;
		* )		echo "Error getting instance status. Please check manually. You may need to shut it down with abort option." >&2
				exit 1;;
esac

# Case for starting the restore/recover in a determined step
case "${STEP:-FULL}" in
		FULL )	echo hola	;&
                SPFILE )	restoreSpfile
				if [ "$?" -ne 0 ]
				then
					echo "Error restoring SPFILE." >&2
					exit 1
				fi;&
		CONTROLFILE )	restoreControlfile
				if [ "$?" -ne 0 ]
				then
					echo "Error restoring CONTROLFILE." >&2
					exit 1
				fi;&
		RESTORE )	restoreDB
				if [ "$?" -ne 0 ]
				then
					echo "Error restoring DATABASE." >&2
					exit 1
				fi;&
		RECOVER )	recoverDB
				if [ "$?" -ne 0 ]
				then
					echo "Error RECOVERING DATABASE." >&2
					exit 1
				fi;&
		CHECK )		checkDB
				if [ "$?" -ne 0 ]
				then
					echo "Error RECOVERING DATABASE." >&2
					exit 1
				fi;;
esac
) > ${LOGDIR}/full_${ORACLE_SID}_${RUNTIME}.log.pipe 2>&1
FULL_RC=$?
rm -f ${LOGDIR}/full_${ORACLE_SID}_${RUNTIME}.log.pipe

if [ -n "${MAILLIST}" ]
then
	echo "Sending email to ${MAILLIST}..."
	mailx -s "DR - Restore ${ORACLE_SID} - `date`" ${MAILLIST} < ${LOGDIR}/full_${ORACLE_SID}_${RUNTIME}.log
	if [ "$?" -ne 0 ]
	then
		echo "Error sending email." >&2
	else
		echo "Done."
	fi
fi

exit "${FULL_RC}"
