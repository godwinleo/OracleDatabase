define param=&1
col name for a50
col CUR_VAL for a30
select i.ksppinm name , v.ksppstvl cur_val, v.ksppstdf default_val,v.ksppstvf
from x$ksppi i, x$ksppcv v 
where i.indx = v.indx 
and i.ksppinm like lower('&param')
/
