set lines 190
set pages 90
set tab off
set trims on
set serveroutput on
set verify off
set sqlprompt "_USER'@'_CONNECT_IDENTIFIER> "
set editfile afiedit.buf.sql
--def _editor = "C:\Documents and Settings\mq38255\gVim\vim73\gvim.exe"
column NAME_COL_PLUS_SHOW_PARAM format A45
column VALUE_COL_PLUS_SHOW_PARAM format A120 word_wrapped
