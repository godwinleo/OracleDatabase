break on reference_index skip 1 on report
compute sum label "Total size of all files in MBytes on diskgroup $2" of mb on report

col type format a25
col files format a80
select decode(aa.alias_directory,'Y',sys_connect_by_path(aa.name,'/'),'N',lpadaa.aa.name) files,  aa.REFERENCE_INDEX,
       b.type, b.blocks, round(b.bytes/1024/1024,0) mb, b.creation_date, b.modification_date
   from v$asm_alias aa,
        (select parent_index from v$asm_alias where group_number = :pindx and alias_index=0) a,
        (select * from v$asm_file where group_number = :pindx) b
   where aa.file_number=b.file_number(+)
   start with aa.PARENT_INDEX=a.parent_index
   connect by prior aa.REFERENCE_INDEX=aa.PARENT_INDEX
   /