SET TERMOUT OFF FEED OFF VERIFY OFF

col Pool format a22 Heading "SGA Pool"
col Megas justify right heading "Size(MB)" format a11
col v_cache_size new_value p_cache_size



SELECT DECODE(SUBSTR( VERSION, 1, INSTR(VERSION, '.')-1), '8',
         '((SELECT VALUE FROM V$PARAMETER WHERE NAME = ''db_block_size'')*BUFFERS/1048576)',
         'CURRENT_SIZE' ) v_cache_size FROM V$INSTANCE
/

SET TERMOUT ON

PROMPT 
PROMPT ORACLE 12.1 DOCUMENTATION
PROMPT 
PROMPT With MEMORY_TARGET set, the SGA_TARGET setting becomes the minimum size of the SGA and the PGA_AGGREGATE_TARGET 
PROMPT setting becomes the minimum size of the instance PGA. By setting both of these to zero as shown, there are no minimums, 
PROMPT and the SGA and instance PGA can grow as needed as long as their sum is less than or equal to the MEMORY_TARGET setting. 
PROMPT The sizing of SQL work areas remains automatic.
PROMPT 
PROMPT You can omit the statements that set the SGA_TARGET and PGA_AGGREGATE_TARGET parameter values to zero and leave either or 
PROMPT both of the values as positive numbers. In this case, the values act as minimum values for the sizes of the SGA or instance PGA.
PROMPT 
PROMPT In addition, you can use the PGA_AGGREGATE_LIMIT initialization parameter to set an instance-wide hard limit for PGA memory. 
PROMPT You can set PGA_AGGREGATE_LIMIT whether or not you use automatic memory management. 
PROMPT 
PROMPT The default value of SGA_MAX_SIZE, when either MEMORY_TARGET or MEMORY_MAX_TARGET is specified, is set to the larger of the two 
PROMPT parameters. This causes more address space to be reserved for expansion of the SGA.
PROMPT


COL PARAMETRO FORMAT A22 HEAD "Parâmetro"
COL "Default" FORMAT A7 HEAD "Default"
COL "Modified" FORMAT A8 HEAD "Modified"
COL "Adjusted" FORMAT A8 HEAD "Adjusted"
COL "Deprecated" FORMAT A10 HEAD "Deprecated"
COL MODIFIABLE FORMAT A20 HEAD "Modifiable"

select upper(name) PARAMETRO
, To_char( value/1048576, '99g999g999') megas
, CASE WHEN ISDEFAULT = 'TRUE' THEN 'YES' ELSE 'NO' END as "Default"
, CASE WHEN ISMODIFIED = 'TRUE' THEN 'YES' ELSE 'NO' END as "Modified"
, CASE WHEN ISADJUSTED = 'TRUE' THEN 'YES' ELSE 'NO' END as "Adjusted"
, CASE WHEN ISDEPRECATED = 'TRUE' THEN 'YES' ELSE 'NO' END as "Deprecated"
, DECODE( ISSES_MODIFIABLE, 'FALSE', DECODE(ISSYS_MODIFIABLE, 'FALSE', 'NO', 'SYSTEM ' || ISSYS_MODIFIABLE), 'SESSION ' || ISSES_MODIFIABLE ) MODIFIABLE
from v$parameter2 where name in ( 'sga_max_size', 'sga_target', 'memory_max_target', 'memory_target', 'pga_aggregate_target', 'pga_aggregate_limit' )
order by
   case name 
     when 'memory_max_target' then 1
     when 'memory_target' then 2
     when 'sga_max_size' then 3
     when 'sga_target' then 4
     else 99
   end  
/

select decode( pool, null, decode(name, 'buffer_cache', 'buffer cache total', 'db_block_buffers', 'buffer cache total',
                                          'fixed_sga', 'fixed sga', 'log_buffer', 'log buffer' ), pool ||
       decode( substr( name, 1, 4 ), 'free', ' free', ' alloc' ) ) Pool ,
       to_char( round(sum(bytes)/1048576,1), '999g990d00' ) Megas
from v$sgastat
group by decode( pool, null, decode(name, 'buffer_cache', 'buffer cache total', 'db_block_buffers', 'buffer cache total',
                                          'fixed_sga', 'fixed sga', 'log_buffer', 'log buffer' ), pool ||
         decode( substr( name, 1, 4 ), 'free', ' free', ' alloc' ) )
UNION
select pool || ' total', to_char( round(sum(bytes)/1048576,1), '999g990d00' )
from v$sgastat
where pool is not null
group by pool
UNION
select 'total SGA', to_char( round(sum(bytes)/1048576,1), '999g990d00' )
from v$sgastat
union
SELECT 'buffer cache ' || lower( name ), to_char( round(&p_cache_size.,1), '999g990d00' ) Megas
FROM V$BUFFER_POOL
WHERE &p_cache_size. > 0
/

col Pool format a22 Heading "PGA Pool"
SELECT POOL, MEGAS
FROM
(
 SELECT
   TO_CHAR( ROUND(VALUE/1048576,1), '999g990d00') MEGAS,
   DECODE( NAME, 'aggregate PGA target parameter', 'PGA Aggregate Target',
                 'aggregate PGA auto target', 'PGA Internal Target',
                 'total PGA inuse', 'Total PGA In Use',
                 'total PGA allocated', 'Total PGA Allocated', 'X' ) POOL
 FROM V$PGASTAT
)
WHERE POOL <> 'X'
/

col Pool  CLEAR
col Megas CLEAR
col Parametro CLEAR
SET FEED 6 VERIFY ON
PROMPT

