select a.ksppinm name, b.ksppstvl value, b.ksppstdf isdefault,
       decode(a.ksppity, 1, 'boolean', 2, 'string', 3, 'number', 4, 'file',
	      a.ksppity) type,
       a.ksppdesc description
from   sys.x$ksppi a, sys.x$ksppcv b
where  a.indx = b.indx
  and  a.ksppinm like '\_%' escape '\'
order  by name
/