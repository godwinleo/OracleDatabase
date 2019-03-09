# DBA Pack

This set of scripts was written for Oracle SQL\*Plus command line utility. It uses SQL\*Plus format commands, like PAGESIZE, LINESIZE, FORMAT, PROMPT and so on. Substitution variables are also widely used.

Once you have downloaded the pack, you should extract the files to a folder pointed by SQLPATH environment variable or even place them in the SQL\*Plus starter folder.

The *login.sql* file is reponsible for several environment sets. You should edit it properly.

## Documentation

### This section intends to be a quick reference guide to the scripts:

#### Enviroment files:

* **login.sql** - Use this file to format the SQL*Plus's login preferences.
```
    Set the OS variable: 
        DEFINE OS=Linux  
        DEFINE OS=Windows.
```
#### Sql files:

 * **asm[d|op].sql** - ASM info. The *asmop* scripts reports only ASM operations.
```
    e.g.
        @asm
        @asmd 
        @asmop
```
 * **awrsql.sql** - Historical information about execution plan for a single SQL, gathered from AWR repo.
```
    @awrsql <sql_id> 
        sql_id - SQL identifier
    e.g.
        @awrsql 9n0dnrf4akbm0
```
 * **circuits.sql** - Shared conection info
 
 * **constraints.sql** - List the constraints associated to a table.
```
    @constraints <owner> <table> 
        owner - the name of the schema   
        table - the name of table(s) to be queried - can use wild cards
    e.g.
        @constraints USR_TESTE T%
```
 
 * **data.sql** - Modifies the date format and prints sysdate.
 *  **dbafreespace[d].sql** - List information about tablespace's free space. For a more detailed report use the *dbafreespaced* script.
```
    @dbafreespace <tablespace> 
        tablespace - the name of tablespace(s) to be queried - can use wild cards
    e.g.
        @dbafreespace %
        @dbafreespaced SYSTEM
```
  
 * **dginst.sql** - Information on running instances and Data Guard status.
 * **dir.sql** - Directory information.
 * **dpmonit.sql** - Datapump monitor. Information on running Data Pump jobs.
 * **excludes.sql** - Lists the available sections for use with expdp/impdp.
```
    @excludes <section> 
        section - The name (or part of it) of the section to be listed.
    e.g.
        @excludes %index%
```
 * **expplan.sql** - This script provides a way to get the execution plan info for a statement. The SQL source code should be placed in the *explain.sql* file along with all other relevant sets, like, current_schema, optimizer options and so on. To get the plan info run the expplan script.
```
    @expplan 
        <no-arguments>
    input file:
        explain.sql
    e.g.
        @expplan 
```
 
 * **fknoindex.sql** - Evaluates all reference constraints (FK) of a named schema and indicates the needs for new index creation to avoid high levels of lock. The output of the script will generate a file name *\<schema\>.FkNoIdx.Sql* and it will contains the DDL for the required new indexes
```
    @fknoindex <schema> 
        schema - The name the scheme whose FKs will be checked.
    e.g.
        @fknoindex usr_ecomm
    output file:
        <schema>.FkNoIdx.Sql
```
 * **getDDLTablespaces.sql** - The script generates the DDL to recreate all the tablespaces of a database. It also normalized the size and number of datafiles for each tablespace. The script accepts a pattern to produce the name of the diskgroup where the datafiles will be created. That is such a hardcoded thing and it can be easily modified. The produced DDL will be placed in a file named *c:\cria.tablespaces.\<pattern\>.sql*.
```
    @getDDLTablespaces <pattern>
        pattern - The pattern will compose the name of the diskgroup for the datafiles, this way: +DG_<pattern>_DATA.
    e.g.
        @getDDLTablespaces ecomm
    output file:
        c:\cria.tablespaces.<pattern>.sql
```
  
 * **getcursor[d].sql** - Lists, in descending order of Logical IO, the cached cursors for a session. The *getcursord* script includes even cursores with low number of reads.
```
    @getcursor <sid>[,serial#][,@inst_id]
        sid - session identifier
        serial# - session serial number
        inst - instance identifier. For non-RAC systems it is always 1.
    e.g.
        @getcursor 1127,93450,@1
        @getcursor 1127,@1
        @getcursor 1127,1
        @getcursor 1127
```
 * **getddl.sql** - Invokes dbms_metadata to extract the DDL for an object. For non-schema objects, such as, tablespaces, the last argument should be an asterisk (\*).
```
    @getddl <objtype> <objowner> <objname>
        objtype - type of the object
        objowner - owner of the object
        objname - name of the object
    e.g.
        @getddl view usr_ecomm vw_list_prod
        @getddl materialized_view usr_ecomm mv_list_prod
        @getddl db_link usr_ecomm mylink.domain
        @getddl tablespace system *
```
 * **getfontes.sql** - Extracts the source for one or more PL/Sql objects of a schema. The script requires a subfolder named *fontes* in which the output files will be placed. Inside it, a folder for each type of object will be created and each object will have its own file.
```
    @getfontes <schema> <objname>
        schema - the owner of the object(s);
        objname - the name of one or more objects using wildcards (%,_).
    e.g.
        @getfontes usr_ecomm pkg_customers
        @getfontes usr_ecomm %
    output file:
       ./fontes/<schema>/<object-type>/<objname>.sql
```
 * **getpfile.sql** - Produces a list of the non-default parameter set in the database. The output can be used to create a parameter file. Deprecated parameter are marked *(--)*.
 
 * **getsql[s].sql** - Reports source, execution statistics and the access plan of a statement. The file getsqls presents only a summary version of the statment
```
    @getsql [{hash|addr|chld}=]<text> 
        text - The text must be the SQL identifier (sql_id), the hash or the address of the statement or even the child_address.
    e.g.
        @getsql gfzzcku5525vf
        @getsql chld=0000000157EA21C0
        @getsqls gfzzcku5525vf
```
 * **getsqltxt.sql** - Searches in the SQL Area for statements containing the text. Can use wildcards.
```
    @getsqltxt <text> <username>
        text - Text to be find in the statement
        username - User parsing the statement
    e.g.
        @getsqltxt "select%cust_id%from%" usr_ecomm
        @getsqltxt "delete%" %
```
 * **histconn.sql** - Returns returns two histograms with connection information for a given connected user. This is useful to examine the pool of connections of an application. The first histogram reports the sessions by creation time and indicates if session is active or no. The second one lists the session by inactivity time.<br>In a good pool of connections, you should find session existing for a long time and being used almost all the time, i.e, short periods of inactivity. 
```
    @histconn <m/s> <username>
        m/s - Indicate the time interval of the buckets of the histogram: it can be in seconds or minutes. 
        username - the name of the connected user.
    e.g.
        @histconn s user_ecomm
        @histconn m user_ecomm
``` 
 * **indexes.sql** - Lists details of a table's indexes.
***Note:*** *Must previously compile the GET_IND_EXPR function. Code included in the body of the script.*
```
    @indexes <table-owner> <table-name>
        table-owner - The owner of the table
        table-name - The name of the table
    e.g.
        @indexes usr_ecomm customers
``` 
 * **jobs[a].sql** - Reports information on old-fashioned jobs created by DBMS_JOB. Use jobsa to get information on running jobs.
```
    @jobs <job-owner> 
        job-owner - The owner of the jobs
    e.g.
        @jobs %
        @jobs usr_ecomm
``` 
 * **limpaobjuser.sql** - ***!!Be careful!!*** - This script drops all objects in a given schema.  
***Note:*** Type "s" to proceed or "N" [default] to abort.
```
    @limpaobjuser <instance-name> <schema-owner> 
        instance-name - It should match the instance name of the DB you are connected to.
        schema-owner - The name of owner of the objects to be dropped
    e.g.
        @limpaobjuser orcl hr
        
        Deseja remover os objetos de hr@orcl (s/N)? _
``` 
  
 * **links.sql** - Lists database links by schemas.
```
    @links <link-owner> <link-name>
        link-owner - The owner the database link
        link-name - The name of the database link
    e.g.
        @links usr_ecomm %
        @links % db_remote.%
``` 
 * **lockmon.sql** - The lock monitor. Lists details about locks in the system. The list is driven by objects.
```
    @lockmon <obj-name>
        obj-name - the name of the object to be listed.
    e.g.
        @lockmon %
        @lockmon %cust%
```  
 * **long[s|ops|all].sql** - These scripts report information on long operations (v$session_longops). The *longs*
 script filters by username. The *longops* and *longall*, in addition to the username, accept the session id (SID) list. The *longall* script reports even finished operations.  
 ***Note:*** SID list can be comma-separated (no spaces allowed) or 0 (zero) for all SIDs.
```
    @longs <username>
        username - the name of the user running long operations
    @long[ops|all] <username> <sid>
        username - the name of the user running long operations
        sid - session identifier
    e.g.
        @longs usr_ecomm
        @longops usr_ecomm 531,533
        @longall usr_ecomm 531
        @longall usr_ecomm 0
```  
 * **monitsegs[d].sql** - Information on the size and wasted space of the objects. Also reports fragmentation info. The *monitsegsd* script details partitions.
```
    @monitsegs <tablespace> <username> <objectname>
        tablespace - the name of tablespace where the objects were created
        username - the name of the objects's owner
        objectname - the name of the objects
    e.g.
        @monitsegs % usr_ecomm %
        @monitsegsd % % customers
        @monitsegs tbs_ecomm % %
```  
 * **nls.sql** - NLS info at different levels: session, instance, database and parameter file.
 
 * **obj.sql** - This scripts reports details of an object (or a set of).
```
    @obj [<i|t|n|o|on|>=]<text>
        i - filter by object id
        t - filter by object type
        n - filter by object name
        o - filter by owner
        on - filter by owner + "." + object_name
        text - the text to search for
    e.g.
        @obj customers
        @obj "t=DATABASE LINK"
        @obj on=usr_ecomm.customer
        @obj on=usr_ecomm.c%
```  
 * **parseas.sql** -  * **parseas.sql** - This is a editable script. It has no arguments, but you can use it as template for parsing (and executing) a statement in the behalf of other schema. This is a non-documented Oracle function.
 * **privobj.sql** - Lists the privileged sources for a given object. Also lists the synonyms for the object. The script produces two files: the first one contains the DDL for grants and create synonyms; the last one contains the DDL for revoking permissions and to drop the synonyms. Useful to assign the same privileges in different databases. Can Use wildcards.
```
    @privobj <owner.object>
        owner.object - the conjuction of owner + object_name.
    e.g.
        @privobj usr_ecomm.customers
        @privobj %cust%
   output file:
        C:\Grant.Privs.SQL
        C:\Revoke.Privs.SQL
```  

 * **privuser[d].sql** - This script generates the DDL to recreate a role/schema, including quotas and system  privileges (if applicable). The *privuserd* script also includes object privileges. In the case of a role, it lists privileged users and roles. ***Note:*** *Must previously compile the STRAGG package and its complements. See [stragg] script.*

 * **profiles.sql**
 * **props.sql**
 * **recursos.sql**
 * **redosec.sql**
 * **resumable.sql**
 * **sched.sql**
 * **sessionwaits.sql**
 * **sesstat.sql**
 * **showplan.sql**
 * **showsga[c].sql**
 * **sort.sql**
 * **stragg.sql**
 * **tops[a|ab|b|k].sql**
 * **topstmt.sql ** - Reports the top N queries with the highest level of logical reads by execution. This script also considers a minimum number of executions of each statement as well a minimum executation rate over the time since when the query was first loaded in the shared pool. Those limits are hardcoded and initially adjusted to 10 and 0,1 (one execution every ten seconds)
 ```
    e.g.
        @topstmt
```  

 * **transactions.sql**
 * **triggers.sql**
 * **undo.sql**
 * **users.sql**
 
## Installation

* Clone the repo or download the zip file;
* Extract the files;
* Point SQLPATH variable to the folder containing the scripts.

## Todo

 - Add Code Comments
 - Write a reference guide for the scripts
 - Replace SQL\*Plus's format commands

License
----

GNU GENERAL PUBLIC LICENSE, Version 2

**Free Software, Hell Yeah!**
