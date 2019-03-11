col event format a35
col "AVG_WAITS(s)" format 990d0000
col time_waited format a16
set verify off
select event, total_waits,
       decode( trunc( time_waited/84600/100, 0 ), 0,
       to_char( to_date('31/01/2001', 'dd/mm/yyyy' )+time_waited/8460000, '"00d:"HH24:MI:SS' ),
       to_char( to_date('31/01/2001', 'dd/mm/yyyy' )+time_waited/8460000, 'DD"d":HH24:MI:SS' ) ) TIME_WAITED,
       round( average_wait/100,4) "AVG_WAITS(s)" from
 ( select * from v$session_event
   where total_waits > 0
   and sid = &1.
   order by total_waits desc )
where rownum < 16
/
set verify on
undefine 1