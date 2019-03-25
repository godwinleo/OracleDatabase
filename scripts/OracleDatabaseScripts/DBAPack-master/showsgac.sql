SET TERMOUT OFF FEED OFF VERIFY OFF

break on inst_id skip 1

col Pool format a22 Heading "SGA Pool"
col Megas justify right heading "Size(MB)" format a11
col v_cache_size new_value p_cache_size

SELECT DECODE(SUBSTR( VERSION, 1, INSTR(VERSION, '.')-1), '8',
         '((SELECT VALUE FROM V$PARAMETER WHERE NAME = ''db_block_size'')*BUFFERS/1048576)',
         'CURRENT_SIZE' ) v_cache_size FROM V$INSTANCE
/

SET TERMOUT ON

COL PARAMETRO FORMAT A22 HEAD "Parâmetro"
select inst_id, upper(name) PARAMETRO, To_char( value/1048576, '99g999g999') megas, ISADJUSTED, ISDEPRECATED 
from gv$parameter2 where name in ( 'sga_max_size', 'sga_target', 'memory_max_target', 'memory_target' )
order by inst_id, 
   case name 
     when 'memory_max_target' then 1
     when 'memory_target' then 2
     when 'sga_max_size' then 3
     when 'sga_target' then 4
     else 99
   end  
/

select inst_id, decode( pool, null, decode(name, 'buffer_cache', 'buffer cache total', 'db_block_buffers', 'buffer cache total',
                                          'fixed_sga', 'fixed sga', 'log_buffer', 'log buffer' ), pool ||
       decode( substr( name, 1, 4 ), 'free', ' free', ' alloc' ) ) Pool ,
       to_char( round(sum(bytes)/1048576,1), '999g990d00' ) Megas
from gv$sgastat
group by inst_id, decode( pool, null, decode(name, 'buffer_cache', 'buffer cache total', 'db_block_buffers', 'buffer cache total',
                                          'fixed_sga', 'fixed sga', 'log_buffer', 'log buffer' ), pool ||
         decode( substr( name, 1, 4 ), 'free', ' free', ' alloc' ) )
UNION
select inst_id, pool || ' total', to_char( round(sum(bytes)/1048576,1), '999g990d00' )
from gv$sgastat
where pool is not null
group by inst_id, pool
UNION
select inst_id, 'total SGA', to_char( round(sum(bytes)/1048576,1), '999g990d00' )
from gv$sgastat
group by inst_id
union
SELECT inst_id, 'buffer cache ' || lower( name ), to_char( round(&p_cache_size.,1), '999g990d00' ) Megas
FROM gV$BUFFER_POOL
WHERE &p_cache_size. > 0
order by 1
/

col Pool format a22 Heading "PGA Pool"
SELECT inst_id, POOL, MEGAS
FROM
(
 SELECT
   inst_id,
   TO_CHAR( ROUND(VALUE/1048576,1), '999g990d00') MEGAS,
   DECODE( NAME, 'aggregate PGA target parameter', 'PGA Aggregate Target',
                 'aggregate PGA auto target', 'PGA Internal Target',
                 'total PGA inuse', 'Total PGA In Use',
                 'total PGA allocated', 'Total PGA Allocated', 'X' ) POOL
 FROM gV$PGASTAT
)
WHERE POOL <> 'X'
order by 1
/

col Pool  CLEAR
col Megas CLEAR
col Parametro CLEAR
SET FEED 6 VERIFY ON
PROMPT

