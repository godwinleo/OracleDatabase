col plan_table_output for a185
select plan_table_output
from table(dbms_xplan.display_awr('&sqlid',nvl('&sqlplan', ''),null,'ADVANCED'))
/
