select type, records_used, records_total,
       records_used/records_total*100 "PCT_USED"
from   sys.v_$controlfile_record_section
/