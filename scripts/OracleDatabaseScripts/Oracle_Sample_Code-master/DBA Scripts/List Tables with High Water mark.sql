set verify off
column owner format a10
column alcblks heading 'Allocated|Blocks' just c
column usdblks heading 'Used|Blocks' just c
column hgwtr heading 'High|Water' just c
break on owner skip page

select
    a.owner,
    a.table_name,
    b.blocks                        alcblks,
    a.blocks                        usdblks,
    (b.blocks-a.empty_blocks-1)     hgwtr
from
    dba_tables a,
    dba_segments b
where
    a.table_name=b.segment_name
    and a.owner=b.owner
    and a.owner not in('SYS','SYSTEM')
    and a.blocks <> (b.blocks-a.empty_blocks-1)
    and a.owner like upper('&owner')||'%'
    and a.table_name like upper('&table_name')||'%'
order by 1,2
/
