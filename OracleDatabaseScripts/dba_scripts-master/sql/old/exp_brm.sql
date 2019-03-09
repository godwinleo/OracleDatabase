col brm for a20
col requestor for a20
col performer for a20
define brm=&1

select vt.job_id,vt.vt_id,vt.requestor,vt.performer,q.submitted,q.finished
,q.tgt_sid ,q.tgt_schema,q.book_date
from imp_vt vt, imp_Queue q
where brm_id =upper('&brm')
and vt.vt_id=q.vt_id
/
