#!/usr/bin/bash
# Author Osama Mustafa
#	This is the default standard profile provided to a user.
#	They are expected to edit it to meet their own needs.

MAIL=/usr/mail/${LOGNAME:?}

ORACLE_BASE=/u01/app/oracle
export ORACLE_BASE
PS1="oracle@`hostname` $ "
export PS1
ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1
export ORACLE_HOME
GRID_HOME=/u01/11.2.0/grid
export GRID_HOME
PATH=$ORACLE_HOME/bin:$GRID_HOME/bin:/usr/bin:$PATH
export PATH
NLS_LANG=AMERICAN_AMERICA.AL32UTF8
export NLS_LANG
TNS_ADMIN=$ORACLE_HOME/network/admin
export TNS_ADMIN
umask 022
#Backup vars
Backup_DIR=/u01/Backup
export Backup_DIR
Backup_EXP_DIR=$Backup_DIR/exports
export Backup_EXP_DIR
Backup_SCRIPT_DIR=$Backup_DIR/scripts
export Backup_SCRIPT_DIR
Backup_LOG_DIR=$Backup_DIR/logs
export Backup_LOG_DIR
Backup_CFS_DIR=$Backup_DIR/SharedCFS
export Backup_CFS_DIR

##################################################
#set credentails
DB_CRED=BACKUP/Backup2012
export DB_CRED

#set db name from tns
DB_NAME=PRDSBL
export DB_NAME

##################################################

