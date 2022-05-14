set echo on
set linesize 300
set pagesize 500
spool BD2C049_TEST.LIS

SELECT COUNT(*) FROM candidates;

spool off
