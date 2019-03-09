set termout off
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss'
/
set termout on
select 'Formato alterado para: ' ||sysdate "Formato de Data" from dual
/

