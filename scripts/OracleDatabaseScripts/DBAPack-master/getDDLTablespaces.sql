col DDL format a140
set pages 0 verify off feed off

define TARGET=&1.
col instance_name new_value inst
col host_name new_value host
col dg new_value dg

set termout off timing off
select 
   instance_name
  ,case when instr(host_name, '.') > 0 
     then substr( host_name, 1, instr(host_name, '.')-1 )
     else host_name
   end host_name
  ,'+DG_'||UPPER('&target.')||'_DATA' dg
from v$instance;
set termout on

spool c:\cria.tablespaces.&TARGET..sql

PROMPT
PROMPT
PROMPT SPOOL c:\cria.tablespaces.&TARGET..log
PROMPT
PROMPT -- IMPRIMINDO INCLUSIVE TABLESPACES VAZIAS
REM PROMPT -- Usando o DiskGroup "&DG." e extensão "EXT."
PROMPT -- Usando o DiskGroup "&DG." somente
PROMPT -- NOTA: Executar como SYS para garantir o privilégio abaixo.

PROMPT
PROMPT CREATE DIRECTORY BKP_WORK  AS '/backup/work'
PROMPT /
PROMPT
PROMPT GRANT UNLIMITED TABLESPACE TO PUBLIC
PROMPT /
PROMPT
PROMPT GRANT EXECUTE ON SYS.DBMS_SYS_SQL TO SYSTEM
PROMPT /
PROMPT

with source as
(
 select lower(name) dbname from v$database
)
,dados as
(
select /*+all_rows use_hash(t f) */
  t.tablespace_name
  , min(t.file_name)||'.' nome_arquivo
  , trunc( ((sum(t.bytes)-(sum(nvl(f.bytes,0))/count(distinct t.file_id)))/1024/1024) +1 ) used_megas
  , count(distinct t.file_id) numfiles
from dba_data_files t
left join (
  select tablespace_name, sum(bytes) bytes 
  from dba_free_space group by tablespace_name 
) f on (t.tablespace_name = f.tablespace_name )
where t.tablespace_name not in 
   ( 'SYS', 'SYSTEM', 'SYSAUX', 'USERS', 'EXAMPLE',
     'UNDOTBS1', 'UNDOTBS2','UNDOTBS3', 'UNDOTBS4', 'UNDOTBS5', 
     'XBD', 'CSMIG', 'CWMLITE','DRSYS','FLOW_1','INDX','ODM','OEM_REPOSITORY' )
--and exists (select 1 from dba_segments where tablespace_name = t.tablespace_name )
group by t.tablespace_name
), dados2 as
(
  select /*+ all_rows no_merge(dados) */
     d.*
    ,replace( substr( nome_arquivo,  
       instr( nome_arquivo, '/' ),  
       instr( nome_arquivo, '.' ) - instr( nome_arquivo, '/' ) ), s.dbname, lower('&TARGET.') ) arquivo
    ,case 
      when used_megas > 10240 then 10240 
      when used_megas > 1024  then 1024
      when used_megas > 128   then 128
      when used_megas > 16    then 16
      when used_megas > 1     then 8
      else 1
    end size_megas
    ,case 
      when used_megas > 10240 then 20480 
      when used_megas > 1000  then 10240
      when used_megas > 100   then 1024
      --when used_megas > 10    then 128
      --when used_megas > 1     then 128
      else 128
    end max_megas
   ,case 
      when used_megas > 10240 then 1024 
      when used_megas > 1000  then 128
      when used_megas > 100   then 16
      when used_megas > 7     then 8
      --when used_megas > 1     then 1
      else 1
    end next_megas
    from dados d
    cross join source s
    order by used_megas desc
)
SELECT 
 'PROMPT '|| TABLESPACE_NAME || ' - ESPACO USADO: '|| used_megas || 'M ' || 
 DECODE(numfiles,1,'',' - POSSUIA '|| numfiles || ' DATAFILES ORIGINALMENTE ' ) || CHR(13)||CHR(10) ||
 'CREATE TABLESPACE '|| TABLESPACE_NAME || CHR(13)||CHR(10) ||
 --'DATAFILE ''&DG.'|| arquivo ||'EXT.''' ||
 'DATAFILE ''&DG.''' ||
 ' SIZE '|| size_megas ||'M REUSE ' || 
 'AUTOEXTEND ON NEXT '|| next_megas ||'M MAXSIZE '|| max_megas ||'M' || CHR(13)||CHR(10) ||
 'EXTENT MANAGEMENT LOCAL AUTOALLOCATE;' || CHR(13)||CHR(10) DDL
FROM dados2
UNION ALL
SELECT 
  '-- ' || SUM( USED_MEGAS ) || 'M ORIGINAL, '|| 
   SUM( SIZE_MEGAS ) || 'M INICIAL, '|| SUM( MAX_MEGAS ) || 'M MAXIMO, ' ||
   COUNT(*) || ' QUANTIDADE' 
FROM dados2
/
PROMPT
PROMPT SPOOL off
PROMPT
spool off

SET verify on pages 66 feed 6
PROMPT -- @getDDLTablespaces.sql &TARGET.
PROMPT
UNDEFINE DG TARGET
--UNDEFINE EXT
