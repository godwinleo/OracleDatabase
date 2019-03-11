define user=&1
col result for a150
select db.name||'|'||userid||'|'||action#||'|'||max(cast ((from_tz(ntimestamp#,'00:00') at local) as date)) result
from AUDITINFO.AUD_HIST$ aud
, v$database db
where action#=100
and userid =upper('&user')
group by userid,action#,db.name;
