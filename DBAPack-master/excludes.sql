SET lines 210 pages 20000 
COL object_path FOR a90 
COL comments FOR a110 

SELECT named, object_path, comments 
FROM database_export_objects  
WHERE upper(comments) like upper('&1') OR upper(OBJECT_PATH) like upper('&1')
/

undefine 1