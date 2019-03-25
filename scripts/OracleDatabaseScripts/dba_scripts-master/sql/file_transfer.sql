accept source_dir char prompt 'source directory : '
accept source_file char prompt 'source file : '
accept dest_dir char prompt 'destionation directory : '
accept dest_db char prompt 'destionation database : '

declare
	v_sourcedir varchar2(100) := '&source_dir';
	v_sourcefile varchar2(100) := '&source_file';
	v_destdir varchar2(100) := '&dest_dir';
	v_destfile varchar2(100) := '&source_file'||'.dbf';
	v_destdb varchar2(100) := '&dest_db';

begin
	
	dbms_output.put_line(' sending file '||v_sourcefile);
	
	DBMS_FILE_TRANSFER.PUT_FILE(
									source_directory_object 		=> v_sourcedir,   
									source_file_name              	=> v_sourcefile,  
									destination_directory_object	=> v_destdir,
									destination_file_name			=> v_destfile,  
									destination_database			=> v_destdb
								);
								
	dbms_output.put_line(' file sent.');

exception
when others then
	dbms_output.put_line(' error ! -> '||SQLERRM);
end;
/