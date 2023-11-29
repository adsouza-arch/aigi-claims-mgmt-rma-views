USE [rmA_Main]
GO

/****** Object:  View [ARCH].[vw_DataStore_Check]    Script Date: 11/29/2023 3:19:20 PM ******/
DROP VIEW [ARCH].[vw_DataStore_Check]
GO

/****** Object:  View [ARCH].[vw_DataStore_Check]    Script Date: 11/29/2023 3:19:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [ARCH].[vw_DataStore_Check]
AS
/*
-- Modification History:
-- Ver		When		Who				  What
-- v1.00	2023-10-24	NGoel			- New Check View CLI-8018
*/

SELECT 
	"X"."ROW_TYP_NM",
	"X"."SRC_SYS_CD",
	"X"."BUS_UNIT_CD",
	"X"."CHECK_KEY",
	"X"."CLM_KEY",
	"X"."CLM_NUM",
	"X"."CHECK_NUM",
	"X"."CHECK_CONTROL_NO",
	"X"."MANUAL_AUTOMATIC_CHECK_NO",
	"X"."CHECK_DT",
	"X"."CHECK_STATUS_CD",
	"X"."PAYMNT_DESC",
	"X"."PAYMNT_CRNCY_CD",
	"X"."PAYMNT_METHOD_CD",
	"X"."PAYEE_NM",
	"X"."PAYEE_TAX_ID_NUM",
	"X"."PAYEE_TAX_ID_TYP_CD",
	"X"."PAYEE_ADDR_LINE_1_TXT",
	"X"."PAYEE_ADDR_LINE_2_TXT",
	"X"."PAYEE_ADDR_LINE_3_TXT",
	"X"."PAYEE_CITY_NM",
	"X"."PAYEE_MAILING_ADDR_TXT",
	"X"."PAYEE_PSTL_CD",
	"X"."PAYEE_STATE_CD",
	"X"."PAYEE_CNTRY_CD",
	"X"."PAYEE_CNTRY_NM",
	"X"."PAYEE_STATE_NM",
	"X"."PAYEE_TYP_CD",
	"X"."CHECK_STOPPED_RSN_TXT",
	"X"."CHECK_BATCH_NUM",
	"X"."SERVICE_FROM_DT",
	"X"."SERVICE_TO_DT",
	"X"."INVOICE_NUM",
	"X"."INVOICE_DT",
	"X"."SRC_SYS_BANK_NUM",
	"X"."BANK_ACCT_NUM",
	"X"."REPORTABLE_1099_TYP_CD",
	"X"."DELIVERY_METHD_TYP_CD",
	"X"."VENDOR_NUM",
	"X"."VENDOR_ADDR_CD"
	,DATEADD(ms, 
				10 * (row_number() 
					  over (
							partition by 
							 "X"."CLM_NUM",
							"X"."ORIG_ROW_UPDT_TS" -- ORIG ROW_UPDT_TS
							order by "X"."CLM_KEY"
							)-1
					  ), 
					"X"."ORIG_ROW_UPDT_TS"
				) AS "ROW_UPDT_TS"	
FROM
	(
		SELECT
           'Check' AS "ROW_TYP_NM"
           , 'RMA' AS "SRC_SYS_CD"
           , 'ALL' AS "BUS_UNIT_CD"
           , 
				CASE
					WHEN ISNULL(cast("FUNDS"."TRANS_ID" as varchar), '') = '' THEN 'No Check'
					ELSE CONCAT ('RMA-ALL-', 'F-', cast("FUNDS"."TRANS_ID" as VARCHAR), '-', 'FTS-', cast("FTS"."SPLIT_ROW_ID" as VARCHAR), '') 
				END "CHECK_KEY"
            , CONCAT ('RMA-ALL-', cast("CLAIM"."CLAIM_ID" as VARCHAR)) AS "CLM_KEY"
			, "CLAIM"."CLAIM_NUMBER" AS "CLM_NUM"
            , "FUNDS"."TRANS_NUMBER" AS "CHECK_NUM"
				--CASE
				--	WHEN ISNULL(cast("FUNDS"."TRANS_NUMBER" as varchar), '') = '' THEN 'No Check'
				--	ELSE "FUNDS"."TRANS_NUMBER"
				--END AS "CHECK_NUM"
			, "FUNDS"."CTL_NUMBER" AS "CHECK_CONTROL_NO"
			, "FUNDS"."TRANS_NUMBER" AS "MANUAL_AUTOMATIC_CHECK_NO"
			,
				CASE
					WHEN ISNULL(cast("FUNDS"."DATE_OF_CHECK" as varchar), '')='' THEN ''
					else cast(concat (substring("FUNDS"."DATE_OF_CHECK", 1, 4), '-', substring("FUNDS"."DATE_OF_CHECK", 5, 2), '-', substring("FUNDS"."DATE_OF_CHECK", 7, 2)) as date)
				END AS "CHECK_DT"
			, "FUND_STATUS"."SHORT_CODE" AS "CHECK_STATUS_CD"
			, "FUNDS"."CHECK_MEMO" AS "PAYMNT_DESC"
			, "CURR"."SHORT_CODE" AS "PAYMNT_CRNCY_CD"
			, "DIST"."SHORT_CODE" AS "PAYMNT_METHOD_CD"
			, CONCAT
				(
					(CASE WHEN ISNULL(cast("FUNDS"."LAST_NAME" as varchar), '')='' THEN '' ELSE "FUNDS"."LAST_NAME" + ' ' END)
				,
					( CASE WHEN ISNULL(cast("FUNDS"."FIRST_NAME" as varchar), '')='' THEN '' ELSE "FUNDS"."FIRST_NAME" END)
				)
				AS "PAYEE_NM"
			, "E"."TAX_ID" AS "PAYEE_TAX_ID_NUM"
			, "TAX_TYP"."CODE_DESC" AS "PAYEE_TAX_ID_TYP_CD"
			, "FUNDS"."ADDR1" AS "PAYEE_ADDR_LINE_1_TXT"
			, "FUNDS"."ADDR2" AS "PAYEE_ADDR_LINE_2_TXT"
			, "E"."ADDR3" AS "PAYEE_ADDR_LINE_3_TXT"
			, "FUNDS"."CITY" AS "PAYEE_CITY_NM"
			, CONCAT( 
					(CASE WHEN ISNULL(cast("A"."ADDR1" as varchar), '')='' THEN '' ELSE "A"."ADDR1" + ',' END)
				, 
					(CASE WHEN ISNULL(cast("A"."ADDR2" as varchar), '')='' THEN '' ELSE "A"."ADDR2" + ',' END)
				,
					(CASE WHEN ISNULL(cast("A"."CITY" as varchar), '')='' THEN '' ELSE "A"."CITY" + ',' END)
				--,
					--(CASE WHEN ISNULL(cast("A"."STATE_ID" as varchar), '')='' THEN '' ELSE "PAY_MAIL_ST"."STATE_ROW_ID" + ',' END)
				,
					(CASE WHEN ISNULL(cast("A"."ZIP_CODE" as varchar), '')='' THEN '' ELSE "A"."ZIP_CODE" END)
				)AS "PAYEE_MAILING_ADDR_TXT"
			, "FUNDS"."ZIP_CODE" AS "PAYEE_PSTL_CD"
			, "PAY_ST"."STATE_ID" AS "PAYEE_STATE_CD"
			, "PY_CNTRY"."SHORT_CODE" AS "PAYEE_CNTRY_CD"
			, "PY_CNTRY"."CODE_DESC" AS "PAYEE_CNTRY_NM"
			, "PAY_ST"."STATE_NAME" AS "PAYEE_STATE_NM"
			, "PAYE_TYP"."CODE_DESC" AS "PAYEE_TYP_CD"
			, "FUNDS"."STOP_PAY_REASON" AS "CHECK_STOPPED_RSN_TXT"
			, "FUNDS"."BATCH_NUMBER" AS "CHECK_BATCH_NUM"
			, CASE
					WHEN ISNULL(cast("FTS"."FROM_DATE" as varchar), '')='' THEN ''
					else cast(concat (substring("FTS"."FROM_DATE", 1, 4), '-', substring("FTS"."FROM_DATE", 5, 2), '-', substring("FTS"."FROM_DATE", 7, 2)) as date)
				END AS "SERVICE_FROM_DT"
			, CASE
					WHEN ISNULL(cast("FTS"."TO_DATE" as varchar), '')='' THEN ''
					else cast(concat (substring("FTS"."TO_DATE", 1, 4), '-', substring("FTS"."TO_DATE", 5, 2), '-', substring("FTS"."TO_DATE", 7, 2)) as date)
				END AS "SERVICE_TO_DT"
			, CASE
					WHEN ISNULL(cast("FTS"."INVOICE_NUMBER" as varchar), '') = '' THEN ''
					ELSE "FTS"."INVOICE_NUMBER"
				END AS "INVOICE_NUM"
			, CASE
					WHEN ISNULL(cast("FTS"."INVOICE_DATE" as varchar), '')='' THEN ''
					else cast(concat (substring("FTS"."INVOICE_DATE", 1, 4), '-', substring("FTS"."INVOICE_DATE", 5, 2), '-', substring("FTS"."INVOICE_DATE", 7, 2)) as date)
				END AS "INVOICE_DT"
			, "FUNDS"."ACCOUNT_ID" AS "SRC_SYS_BANK_NUM"
			, "ACCT".ACCOUNT_NUMBER AS "BANK_ACCT_NUM"
			, "1099"."SHORT_CODE" AS "REPORTABLE_1099_TYP_CD"
			, "DIST"."SHORT_CODE" AS "DELIVERY_METHD_TYP_CD"
			, "ENT_ID"."ID_NUM" AS "VENDOR_NUM"
			, NULL AS "VENDOR_ADDR_CD"
			,
				CAST(CONCAT( SUBSTRING("FUNDS"."DTTM_RCD_ADDED", 1, 4) , '-' , SUBSTRING("FUNDS"."DTTM_RCD_ADDED", 5, 2) , '-' , SUBSTRING("FUNDS"."DTTM_RCD_ADDED", 7, 2) , ' ' ,
				CASE 
					WHEN SUBSTRING("FUNDS"."DTTM_RCD_ADDED", 9, 2) = '' THEN '0' 
					ELSE SUBSTRING("FUNDS"."DTTM_RCD_ADDED", 9, 2) 
				END , ':' ,
				CASE
					WHEN SUBSTRING("FUNDS"."DTTM_RCD_ADDED", 11, 2) = '' THEN '00'
					ELSE SUBSTRING("FUNDS"."DTTM_RCD_ADDED", 11, 2) END , ':' ,
				CASE
					WHEN SUBSTRING("FUNDS"."DTTM_RCD_ADDED", 13, 2) = '' THEN '00'
					ELSE SUBSTRING("FUNDS"."DTTM_RCD_ADDED", 13, 2) END) as datetime)   
				AS "ORIG_ROW_UPDT_TS"

        FROM "rmA_main"."dbo"."FUNDS" "FUNDS" (NOLOCK)
        INNER JOIN "rmA_Main"."dbo"."CLAIM" "CLAIM" (NOLOCK) 
			ON "FUNDS"."CLAIM_ID" = "CLAIM"."CLAIM_ID"
        INNER JOIN "rmA_Main"."dbo"."FUNDS_TRANS_SPLIT" "FTS" (NOLOCK) 
			ON "FTS"."TRANS_ID" = "FUNDS"."TRANS_ID"
        INNER JOIN "rmA_Main"."dbo"."ENTITY" "E" (NOLOCK) 
			ON "E"."ENTITY_ID" = "FUNDS"."PAYEE_EID"
        LEFT JOIN "rmA_Main"."dbo"."CODES_TEXT" "TAX_TYP" (NOLOCK) 
			ON "TAX_TYP"."CODE_ID" = "E"."ID_TYPE"
	    LEFT JOIN "rmA_Main"."dbo"."ADDRESS" "A" (NOLOCK) 
			ON "A"."ADDRESS_ID" = "FUNDS"."MAIL_TO_ADDRESS_ID"
		LEFT JOIN "rmA_Main"."dbo"."STATES" "PAY_MAIL_ST" (NOLOCK) 
			ON "PAY_MAIL_ST"."STATE_ROW_ID" = "A"."STATE_ID"
        LEFT JOIN "rmA_main"."dbo"."CODES_TEXT" "CURR" (NOLOCK) 
			ON "CURR"."CODE_ID" = "FUNDS"."PMT_CURRENCY_CODE"
        LEFT JOIN "rmA_Main"."dbo"."CODES_TEXT" "FUND_STATUS" (NOLOCK) 
			ON "FUND_STATUS"."CODE_ID" = "FUNDS"."STATUS_CODE"	
		LEFT JOIN "rmA_main"."dbo"."CODES_TEXT" "DIST" (NOLOCK)
			ON "DIST"."CODE_ID" = "FUNDS"."DSTRBN_TYPE_CODE"
		LEFT JOIN "rmA_Main"."dbo"."STATES" "PAY_ST" (NOLOCK) 
			ON "PAY_ST"."STATE_ROW_ID" = "FUNDS"."STATE_ID"
		LEFT JOIN "rmA_Main"."dbo"."CODES_TEXT" "PY_CNTRY" (NOLOCK) 
			ON "PY_CNTRY"."CODE_ID" = "FUNDS"."COUNTRY_CODE"
		LEFT JOIN "rmA_Main"."dbo"."CODES_TEXT" "PAYE_TYP" (NOLOCK) 
			ON "PAYE_TYP"."CODE_ID" = "FUNDS"."PAYEE_TYPE_CODE"
		LEFT JOIN "rmA_Main"."dbo"."ACCOUNT" "ACCT" (NOLOCK) 
			ON "ACCT"."ACCOUNT_ID" = "FUNDS"."ACCOUNT_ID"
		LEFT JOIN "rmA_Main"."dbo"."ENTITY_SUPP" "ES" (NOLOCK) 
			ON "ES"."ENTITY_ID" = "E"."ENTITY_ID" 
		LEFT JOIN "rmA_Main"."dbo"."CODES_TEXT" "1099" (NOLOCK) 
			ON "ES"."RPTTYP_1099_CODE" = "1099"."CODE_ID"
		LEFT JOIN --"rmA_Main"."dbo"."ENT_ID_TYPE" "ENT_ID" (NOLOCK) ON "ENT_ID"."ENTITY_ID" = "E"."ENTITY_ID"
					(
				SELECT
					"ENT_ID"."ENTITY_ID", MIN("ENT_ID"."ID_NUM_ROW_ID") AS "MIN_ROW"
				FROM
					"rmA_Main"."dbo"."ENT_ID_TYPE" "ENT_ID" (NOLOCK) 
				WHERE 1=1
				GROUP BY "ENT_ID".ENTITY_ID
			)"ENTIDTYPE" ON "ENTIDTYPE"."ENTITY_ID" = "E"."ENTITY_ID"
		LEFT JOIN "rmA_Main"."dbo"."ENT_ID_TYPE" "ENT_ID" (NOLOCK) ON "ENT_ID"."ID_NUM_ROW_ID" = "ENTIDTYPE"."MIN_ROW"
WHERE 1=1 
)"X"

GO


