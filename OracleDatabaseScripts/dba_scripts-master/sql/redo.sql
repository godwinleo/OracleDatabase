set pagesize 10
set verify off
set colsep ""
col 00 for 999
col 01 for 999
col 02 for 999
col 03 for 999
col 04 for 999
col 05 for 999
col 06 for 999
col 07 for 999
col 08 for 999
col 09 for 999
col 10 for 999
col 11 for 999
col 12 for 999
col 13 for 999
col 14 for 999
col 15 for 999
col 16 for 999
col 17 for 999
col 18 for 999
col 19 for 999
col 20 for 999
col 21 for 999
col 22 for 999
col 23 for 999
col 24 for 999
col TOT for 9999

SELECT  To_Char(FIRST_TIME,'YYYY-MM-DD DAY') "DAY/HOUR",
        SUM(Decode(To_Number(To_Char(FIRST_TIME,'HH24')),0,1,0))  "00",
        SUM(Decode(To_Number(To_Char(FIRST_TIME,'HH24')),1,1,0))  "01",
        SUM(Decode(To_Number(To_Char(FIRST_TIME,'HH24')),2,1,0))  "02",
        SUM(Decode(To_Number(To_Char(FIRST_TIME,'HH24')),3,1,0))  "03",
        SUM(Decode(To_Number(To_Char(FIRST_TIME,'HH24')),4,1,0))  "04",
        SUM(Decode(To_Number(To_Char(FIRST_TIME,'HH24')),5,1,0))  "05",
        SUM(Decode(To_Number(To_Char(FIRST_TIME,'HH24')),6,1,0))  "06",
        SUM(Decode(To_Number(To_Char(FIRST_TIME,'HH24')),7,1,0))  "07",
        SUM(Decode(To_Number(To_Char(FIRST_TIME,'HH24')),8,1,0))  "08",
        SUM(Decode(To_Number(To_Char(FIRST_TIME,'HH24')),9,1,0))  "09",
        SUM(Decode(To_Number(To_Char(FIRST_TIME,'HH24')),10,1,0)) "10",
        SUM(Decode(To_Number(To_Char(FIRST_TIME,'HH24')),11,1,0)) "11",
        SUM(Decode(To_Number(To_Char(FIRST_TIME,'HH24')),12,1,0)) "12",
        SUM(Decode(To_Number(To_Char(FIRST_TIME,'HH24')),13,1,0)) "13",
        SUM(Decode(To_Number(To_Char(FIRST_TIME,'HH24')),14,1,0)) "14",
        SUM(Decode(To_Number(To_Char(FIRST_TIME,'HH24')),15,1,0)) "15",
        SUM(Decode(To_Number(To_Char(FIRST_TIME,'HH24')),16,1,0)) "16",
        SUM(Decode(To_Number(To_Char(FIRST_TIME,'HH24')),17,1,0)) "17",
        SUM(Decode(To_Number(To_Char(FIRST_TIME,'HH24')),18,1,0)) "18",
        SUM(Decode(To_Number(To_Char(FIRST_TIME,'HH24')),19,1,0)) "19",
        SUM(Decode(To_Number(To_Char(FIRST_TIME,'HH24')),20,1,0)) "20",
        SUM(Decode(To_Number(To_Char(FIRST_TIME,'HH24')),21,1,0)) "21",
        SUM(Decode(To_Number(To_Char(FIRST_TIME,'HH24')),22,1,0)) "22",
        SUM(Decode(To_Number(To_Char(FIRST_TIME,'HH24')),23,1,0)) "23",
        SUM(Decode(To_Number(To_Char(FIRST_TIME,'HH24')),99,1,1))"TOT"
  FROM V$LOG_HISTORY
GROUP BY To_Char(FIRST_TIME,'YYYY-MM-DD DAY')
order by 1;


set colsep " "
set pagesize 40