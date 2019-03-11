col name for a20
select a.* , max(max_applied) over (partition by dest_id) max_total_seq
from 
(	select ads.dest_id, ads.DB_UNIQUE_NAME name
		, applied, count (*) amount,to_char(max(completion_time),'YYYY-MON-DD HH24:MI:SS') last_completed
		, max(sequence#) max_applied
		, min(sequence#) max_shipped
		--, max (sequence#) over ( partition by applied)
	from v$archived_log al
		, v$archive_dest_status ads
	where ads.dest_id=al.dest_id
		and ads.status!='INACTIVE'
		and al.applied!='YES'
	group by ads.dest_id, ads.DB_UNIQUE_NAME, applied
) a
where a.dest_id <> 1
	order by dest_id, amount
/
