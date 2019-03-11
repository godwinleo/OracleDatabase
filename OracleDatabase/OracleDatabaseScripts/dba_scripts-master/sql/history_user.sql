define user=&1
col username for a30

select u.name username, uh.USER#, uh.PASSWORD
,to_date(PASSWORD_DATE,'YYYY-MON-DD HH24:MI:SS') password_date
from sys.user_history$ uh, sys.user$ u
where u.user#=uh.user#
and u.name like upper('&user')
order by password_date
/