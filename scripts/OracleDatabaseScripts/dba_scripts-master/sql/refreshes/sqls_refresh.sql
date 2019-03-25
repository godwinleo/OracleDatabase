update imp_queue set status='DONE' where job_id=3160



exec imp_util.delete_job(1851);
