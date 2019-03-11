set echo off
define sess=&1
set feed on
alter system kill session '&sess';
