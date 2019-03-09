define rep=&1
select sys.DBMS_HM.GET_RUN_REPORT(upper('&rep'))
from dual
/
