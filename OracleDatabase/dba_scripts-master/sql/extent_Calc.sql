define num_rows=&1
define avg_row_len=&2
select 
round(num_rows*avg_row_len/1024/16,2) as extents_16kb
,round(num_rows*avg_row_len/1024/32,2) as extents_32kb
,round(num_rows*avg_row_len/1024/64,2) as extents_64kb
,round(num_rows*avg_row_len/1024/128,2) as extents_128kb
,round(num_rows*avg_row_len/1024/256,2) as extents_256kb
,round(num_rows*avg_row_len/1024/1024/1,2) as extents_1mb
,round(num_rows*avg_row_len/1024/1024/2,2) as extents_2mb
,round(num_rows*avg_row_len/1024/1024/4,2) as extents_4mb
,round(num_rows*avg_row_len/1024/1024/8,2) as extents_8mb
from
	( select &rows num_rows, &row_len avg_row_len, 30 extents from dual)
/
