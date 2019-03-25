DECLARE
   cl_sql_text   CLOB;
BEGIN
   SELECT     sql_text
     INTO     cl_sql_text
     FROM     dba_hist_sqltext
    WHERE     sql_id = '6r5736z0x43ca';

   DBMS_SQLTUNE.import_sql_profile (
      sql_text      => cl_sql_text,
      profile       => sqlprof_attr (
                         'ALL_ROWS',
                         'OUTLINE_LEAF(@"SEL$5")',
                         'OUTLINE_LEAF(@"SEL$2")',
                         'OUTLINE_LEAF(@"SEL$3")',
                         'OUTLINE_LEAF(@"SET$1")',
                         'OUTLINE_LEAF(@"SEL$7")',
                         'OUTLINE_LEAF(@"SEL$6")',
                         'OUTLINE_LEAF(@"SET$3")',
                         'OUTLINE_LEAF(@"SEL$EA451647")',
                         'MERGE(@"SEL$4")',
                         'MERGE(@"SEL$8")',
                         'OUTLINE_LEAF(@"SEL$9")',
                         'OUTLINE_LEAF(@"SEL$10")',
                         'OUTLINE_LEAF(@"SEL$862B438F")',
                         'UNNEST(@"SEL$12")',
                         'OUTLINE_LEAF(@"SEL$13")',
                         'OUTLINE_LEAF(@"SET$2")',
                         'OUTLINE(@"SEL$1")',
                         'OUTLINE(@"SEL$4")',
                         'OUTLINE(@"SEL$8")',
                         'OUTLINE(@"SEL$11")',
                         'OUTLINE(@"SEL$12")',
                         'INDEX(@"SEL$13" "URSIN"@"SEL$13" ("URYR_RPT_SEC_ITEM_NO"."REPORT_CODE" "URYR_RPT_SEC_ITEM_NO"."REPORT_SECTION" "URYR_RPT_SEC_ITEM_NO"."ITEM_NO" "URYR_RPT_SEC_ITEM_NO"."SUB_REP_NO" "URYR_RPT_SEC_ITEM_NO"."QRY_NO" "URYR_RPT_SEC_ITEM_NO"."DUMMY_FIELD1" "URYR_RPT_SEC_ITEM_NO"."DUMMY_FIELD2" "URYR_RPT_SEC_ITEM_NO"."DUMMY_FIELD3" "URYR_RPT_SEC_ITEM_NO"."DUMMY_FIELD4" "URYR_RPT_SEC_ITEM_NO"."DUMMY_FIELD5" "URYR_RPT_SEC_ITEM_NO"."DUMMY_FIELD6"))',
                         'INDEX(@"SEL$13" "MAP"@"SEL$13" ("URYR_CBDR_ACCT_TO_REPORT_M"."REPORT_CODE" "URYR_CBDR_ACCT_TO_REPORT_M"."REPORT_SECTION" "URYR_CBDR_ACCT_TO_REPORT_M"."DERIVED_CBDR_ACCOUNT"))',
                         'FULL(@"SEL$13" "UCR"@"SEL$13")',
                         'FULL(@"SEL$13" "UCM1"@"SEL$13")',
                         'INDEX_RS_ASC(@"SEL$13" "MAP2"@"SEL$13" ("URYR_CBDR_ACCT_TO_REPORT_M"."REPORT_CODE" "URYR_CBDR_ACCT_TO_REPORT_M"."REPORT_SECTION" "URYR_CBDR_ACCT_TO_REPORT_M"."DERIVED_CBDR_ACCOUNT"))',
                         'FULL(@"SEL$13" "UCM2"@"SEL$13")',
                         'LEADING(@"SEL$13" "URSIN"@"SEL$13" "MAP"@"SEL$13" "UCR"@"SEL$13" "UCM1"@"SEL$13" "MAP2"@"SEL$13" "UCM2"@"SEL$13")',
                         'USE_MERGE_CARTESIAN(@"SEL$13" "MAP"@"SEL$13")',
                         'USE_HASH(@"SEL$13" "UCR"@"SEL$13")',
                         'USE_HASH(@"SEL$13" "UCM1"@"SEL$13")',
                         'USE_NL(@"SEL$13" "MAP2"@"SEL$13")',
                         'USE_HASH(@"SEL$13" "UCM2"@"SEL$13")',
                         'SWAP_JOIN_INPUTS(@"SEL$13" "UCM1"@"SEL$13")',
                         'SWAP_JOIN_INPUTS(@"SEL$13" "UCM2"@"SEL$13")',
                         'INDEX(@"SEL$862B438F" "URSIN"@"SEL$11" ("URYR_RPT_SEC_ITEM_NO"."REPORT_CODE" "URYR_RPT_SEC_ITEM_NO"."REPORT_SECTION" "URYR_RPT_SEC_ITEM_NO"."ITEM_NO" "URYR_RPT_SEC_ITEM_NO"."SUB_REP_NO" "URYR_RPT_SEC_ITEM_NO"."QRY_NO" "URYR_RPT_SEC_ITEM_NO"."DUMMY_FIELD1" "URYR_RPT_SEC_ITEM_NO"."DUMMY_FIELD2" "URYR_RPT_SEC_ITEM_NO"."DUMMY_FIELD3" "URYR_RPT_SEC_ITEM_NO"."DUMMY_FIELD4" "URYR_RPT_SEC_ITEM_NO"."DUMMY_FIELD5" "URYR_RPT_SEC_ITEM_NO"."DUMMY_FIELD6"))',
                         'INDEX(@"SEL$862B438F" "MAP"@"SEL$11" ("URYR_CBDR_ACCT_TO_REPORT_M"."REPORT_CODE" "URYR_CBDR_ACCT_TO_REPORT_M"."REPORT_SECTION" "URYR_CBDR_ACCT_TO_REPORT_M"."DERIVED_CBDR_ACCOUNT"))',
                         'FULL(@"SEL$862B438F" "UCR"@"SEL$11")',
                         'FULL(@"SEL$862B438F" "URYRR_CENTRAL_RIESGOS_DET_ADJ"@"SEL$12")',
                         'FULL(@"SEL$862B438F" "UCM1"@"SEL$11")',
                         'INDEX_RS_ASC(@"SEL$862B438F" "MAP2"@"SEL$11" ("URYR_CBDR_ACCT_TO_REPORT_M"."REPORT_CODE" "URYR_CBDR_ACCT_TO_REPORT_M"."REPORT_SECTION" "URYR_CBDR_ACCT_TO_REPORT_M"."DERIVED_CBDR_ACCOUNT"))',
                         'FULL(@"SEL$862B438F" "UCM2"@"SEL$11")',
                         'LEADING(@"SEL$862B438F" "URSIN"@"SEL$11" "MAP"@"SEL$11" "UCR"@"SEL$11" "URYRR_CENTRAL_RIESGOS_DET_ADJ"@"SEL$12" "UCM1"@"SEL$11" "MAP2"@"SEL$11" "UCM2"@"SEL$11")',
                         'USE_MERGE_CARTESIAN(@"SEL$862B438F" "MAP"@"SEL$11")',
                         'USE_HASH(@"SEL$862B438F" "UCR"@"SEL$11")',
                         'USE_HASH(@"SEL$862B438F" "URYRR_CENTRAL_RIESGOS_DET_ADJ"@"SEL$12")',
                         'USE_HASH(@"SEL$862B438F" "UCM1"@"SEL$11")',
                         'USE_NL(@"SEL$862B438F" "MAP2"@"SEL$11")',
                         'USE_HASH(@"SEL$862B438F" "UCM2"@"SEL$11")',
                         'INDEX(@"SEL$10" "URSIN"@"SEL$10" ("URYR_RPT_SEC_ITEM_NO"."REPORT_CODE" "URYR_RPT_SEC_ITEM_NO"."REPORT_SECTION" "URYR_RPT_SEC_ITEM_NO"."ITEM_NO" "URYR_RPT_SEC_ITEM_NO"."SUB_REP_NO" "URYR_RPT_SEC_ITEM_NO"."QRY_NO" "URYR_RPT_SEC_ITEM_NO"."DUMMY_FIELD1" "URYR_RPT_SEC_ITEM_NO"."DUMMY_FIELD2" "URYR_RPT_SEC_ITEM_NO"."DUMMY_FIELD3" "URYR_RPT_SEC_ITEM_NO"."DUMMY_FIELD4" "URYR_RPT_SEC_ITEM_NO"."DUMMY_FIELD5" "URYR_RPT_SEC_ITEM_NO"."DUMMY_FIELD6"))',
                         'FULL(@"SEL$10" "UCR"@"SEL$10")',
                         'FULL(@"SEL$10" "MAP"@"SEL$10")',
                         'LEADING(@"SEL$10" "URSIN"@"SEL$10" "UCR"@"SEL$10" "MAP"@"SEL$10")',
                         'USE_MERGE_CARTESIAN(@"SEL$10" "UCR"@"SEL$10")',
                         'USE_HASH(@"SEL$10" "MAP"@"SEL$10")',
                         'SWAP_JOIN_INPUTS(@"SEL$10" "MAP"@"SEL$10")',
                         'INDEX(@"SEL$9" "URSIN"@"SEL$9" ("URYR_RPT_SEC_ITEM_NO"."REPORT_CODE" "URYR_RPT_SEC_ITEM_NO"."REPORT_SECTION" "URYR_RPT_SEC_ITEM_NO"."ITEM_NO" "URYR_RPT_SEC_ITEM_NO"."SUB_REP_NO" "URYR_RPT_SEC_ITEM_NO"."QRY_NO" "URYR_RPT_SEC_ITEM_NO"."DUMMY_FIELD1" "URYR_RPT_SEC_ITEM_NO"."DUMMY_FIELD2" "URYR_RPT_SEC_ITEM_NO"."DUMMY_FIELD3" "URYR_RPT_SEC_ITEM_NO"."DUMMY_FIELD4" "URYR_RPT_SEC_ITEM_NO"."DUMMY_FIELD5" "URYR_RPT_SEC_ITEM_NO"."DUMMY_FIELD6"))',
                         'FULL(@"SEL$9" "UCR"@"SEL$9")',
                         'INDEX_RS_ASC(@"SEL$9" "MAP"@"SEL$9" ("URYR_CBDR_ACCT_TO_REPORT_M"."REPORT_CODE" "URYR_CBDR_ACCT_TO_REPORT_M"."REPORT_SECTION" "URYR_CBDR_ACCT_TO_REPORT_M"."DERIVED_CBDR_ACCOUNT"))',
                         'LEADING(@"SEL$9" "URSIN"@"SEL$9" "UCR"@"SEL$9" "MAP"@"SEL$9")',
                         'USE_MERGE_CARTESIAN(@"SEL$9" "UCR"@"SEL$9")',
                         'USE_NL(@"SEL$9" "MAP"@"SEL$9")',
                         'NO_ACCESS(@"SEL$EA451647" "from$_subquery$_004"@"SEL$4")',
                         'FULL(@"SEL$EA451647" "URYR_CBDR_ACCT_TO_REPORT_M"@"SEL$8")',
                         'LEADING(@"SEL$EA451647" "from$_subquery$_004"@"SEL$4" "URYR_CBDR_ACCT_TO_REPORT_M"@"SEL$8")',
                         'USE_HASH(@"SEL$EA451647" "URYR_CBDR_ACCT_TO_REPORT_M"@"SEL$8")',
                         'SWAP_JOIN_INPUTS(@"SEL$EA451647" "URYR_CBDR_ACCT_TO_REPORT_M"@"SEL$8")',
                         'NO_ACCESS(@"SEL$6" "MAP"@"SEL$6")',
                         'NO_ACCESS(@"SEL$6" "COA"@"SEL$6")',
                         'FULL(@"SEL$6" "UCM"@"SEL$6")',
                         'LEADING(@"SEL$6" "MAP"@"SEL$6" "COA"@"SEL$6" "UCM"@"SEL$6")',
                         'USE_HASH(@"SEL$6" "COA"@"SEL$6")',
                         'USE_HASH(@"SEL$6" "UCM"@"SEL$6")',
                         'SWAP_JOIN_INPUTS(@"SEL$6" "UCM"@"SEL$6")',
                         'FULL(@"SEL$5" "UCR"@"SEL$5")',
                         'FULL(@"SEL$7" "URYR_CBDR_ACCT_TO_REPORT_M"@"SEL$7")',
                         'FULL(@"SEL$3" "URYR_COA_MONTHLY_ADJ"@"SEL$3")',
                         'INDEX_SS(@"SEL$2" "URYR_COA_DAILY_ADJ"@"SEL$2" ("URYR_COA_DAILY_ADJ"."ACCOUNT_NUMBER" "URYR_COA_DAILY_ADJ"."BOOK_DATE"))'
                      ),
      name          => 'TNLRUY_CONTROLES_CR',
      force_match   => TRUE
   );
END;
/

SELECT     * FROM dba_sql_profiles

exec dbms_sqltune.drop_sql_profile('TNLRUY_CONTROLES_CR', TRUE)

BEGIN
  DBMS_SQLTUNE.alter_sql_profile (
    name            => 'TNLRUY_CONTROLES_CR',
    attribute_name  => 'STATUS',
    value           => 'DISABLED');
END;
/


proxy.citicorp.com
