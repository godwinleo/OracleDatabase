define id=&1
select * from table (dbms_xplan.display_cursor('&id'))
/
