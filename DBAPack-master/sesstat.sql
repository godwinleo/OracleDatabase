set pages 300 verify off feed off

col name format a80 heading "Estatísticas de Sessão"
col class noprint
col classe format a10
col moving format a50 head "Estatisticas (Variação durante a execução do comando)"
col cls_where new_value cls_where 
define p_sid = &1.
define p_inst = &2.
define p_classe = &3.

set termout off
select 
   case when substr( '&p_classe.',1,1 ) = '@' 
     then 'where lower(classe) like ''%'' || lower(  substr(''&p_classe.'',2,100) ) || ''%'''
     else 'where lower(name) like ''%'' || lower(  ''&p_classe.'' ) || ''%'''
   end cls_where    
from dual
/
set termout on

CREATE GLOBAL TEMPORARY TABLE TMP_S1 
AS SELECT 
    n.statistic#
   ,n.class
   ,s.value
   ,n.name 
   ,decode( n.class, 1, 'User', 2, 'Redo', 4, 'Enqueue', 72, 'Cache', 
                     8, 'Cache', 16, 'OS', 32, 'RAC', 64, 'SQL', 128, 'Debug', 'Outra' ) classe
from gv$statname n, gv$sesstat s
where s.statistic# = n.statistic# and s.inst_id = n.inst_id
and s.value > 0
and s.sid = &p_sid.
and s.inst_id = &p_inst
/

CREATE GLOBAL TEMPORARY TABLE TMP_S2 
AS SELECT * FROM TMP_S1
/

INSERT INTO TMP_S1
SELECT 
    n.statistic#
   ,n.class
   ,s.value
   ,n.name 
   ,decode( n.class, 1, 'User', 2, 'Redo', 4, 'Enqueue', 72, 'Cache', 
                     8, 'Cache', 16, 'OS', 32, 'RAC', 64, 'SQL', 128, 'Debug', 'Outra' ) classe
from gv$statname n, gv$sesstat s
where s.statistic# = n.statistic# and s.inst_id = n.inst_id
and s.value > 0
and s.sid = &p_sid.
and s.inst_id = &p_inst
/

break on class skip 1

select * from
(
select
   --n.statistic#,
   n.class,
   LPAD(
   decode(sign(1e+12-s.value), -1, to_char(s.value/1e+09, 'fm999g999g999' ) || 'G',
   decode(sign(1e+09-s.value), -1, to_char(s.value/1e+06, 'fm999g999g999' ) || 'M',
   decode(sign(1e+06-s.value), -1, to_char(s.value/1e+03, 'fm999g999g999' ) || 'K',
   to_char(s.value, 'fm999g999g999' )  ) ) ), 15, ' ' ) || ' of ' || initcap( n.name ) name,
   decode( n.class, 1, 'User', 2, 'Redo', 4, 'Enqueue', 72, 'Cache', 8, 'Cache', 16, 'OS', 32, 'RAC', 64, 'SQL', 128, 'Debug', 'Outra' ) classe
from gv$statname n, gv$sesstat s
where s.statistic# = n.statistic# and s.inst_id = n.inst_id
and s.value > 0
and s.sid = &p_sid.
and s.inst_id = &p_inst
order by n.class, s.value desc
)
&cls_where.
/

INSERT INTO TMP_S2
SELECT 
    n.statistic#
   ,n.class
   ,s.value
   ,n.name 
   ,decode( n.class, 1, 'User', 2, 'Redo', 4, 'Enqueue', 72, 'Cache', 
                     8, 'Cache', 16, 'OS', 32, 'RAC', 64, 'SQL', 128, 'Debug', 'Outra' ) classe
from gv$statname n, gv$sesstat s
where s.statistic# = n.statistic# and s.inst_id = n.inst_id
and s.value > 0
and s.sid = &p_sid.
and s.inst_id = &p_inst
/

PROMPT DELTA
SELECT 
   t2.class,
   LPAD(
   decode(sign(1e+12-t2.value), -1, to_char(t2.value/1e+09, 'fm999g999g999' ) || 'G',
   decode(sign(1e+09-t2.value), -1, to_char(t2.value/1e+06, 'fm999g999g999' ) || 'M',
   decode(sign(1e+06-t2.value), -1, to_char(t2.value/1e+03, 'fm999g999g999' ) || 'K',
   to_char(t2.value, 'fm999g999g999' )  ) ) ), 15, ' ' ) || ' of ' || initcap( t2.name ) name,
   t2.classe, t2.statistic#
FROM TMP_S2 T2
JOIN TMP_S1 T1 ON (T1.STATISTIC# = T2.STATISTIC#)
WHERE NVL(T1.VALUE, 0) <> NVL(T2.VALUE,0)
/
PROMPT DELTA

select 
  case when sum(t1.value)-sum(t2.value) = 0 
    then 'Parado em ' || sum(t2.value) || ' estatísticas.' 
    else 'Durante o comando '|| to_char( sum(t2.value) - sum(t1.value) ) ||' estatísticas.' 
  end moving 
FROM TMP_S2 T2
JOIN TMP_S1 T1 ON (T1.STATISTIC# = T2.STATISTIC#)
/

DROP TABLE TMP_S1;
DROP TABLE TMP_S2;

PROMPT
PROMPT EXECUTADO @sesstat &p_sid. &p_inst. &p_classe.
PROMPT

set pages 66 verify on feed 6
undefine 1 2 p_sid p_classe
col class clear
col name clear
col classe clear
col cls_where clear
undef cls_where 


