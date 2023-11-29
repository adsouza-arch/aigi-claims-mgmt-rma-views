USE [rmA_Main]
GO

/****** Object:  View [ARCH].[vw_DataStore_Claim]    Script Date: 11/8/2023 9:07:42 PM ******/
DROP VIEW [ARCH].[vw_DataStore_Claim]
GO

/****** Object:  View [ARCH].[vw_DataStore_Claim]    Script Date: 11/8/2023 9:07:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [ARCH].[vw_DataStore_Claim]
AS


-- Description:  RMA CLAIM source abstraction query
--
-- Modification History:
--
-- Ver		When		Who				What
-- v3.11	2023-05-26	ADsouza			- CLI-7253 Sourcing EA data elements i.e. CLM_REINSU_FLAG, CLM_REOPENED_DT.
-- v3.10	2023-05-24	ADsouza			- CLI-7279 Remove Vehicle Fields as part of Exposure Query.
-- v3.09	2023-04-26	Adsouza			- CLI-6174 - Added the “Monitoring File" Indicator and "Matter Type" fields.
-- v3.08	2023-04-20	NG				- Added Insured Vehicle and Claimant Vehicle logic and columns
-- v3.07	2023-03-02	NG				- Added Reinsurance Report Claim supp field:"CLI_REINREP_CODE"
-- v3.06	2022-08-10	NG				- Merged code from ED Claim view query and removed code for Alt Markets
-- v3.05	2022-07-25	NG				- removed the code for EA Liability loss supp and moved to exposure view
-- v3.05	2022-06-07	AApkar			- Added Alt Markets supplemental fields.	
-- v3.04	2022-05-11	Pallavi Dhole	- Added 10 ms only for duplicate records for nat key & row updt ts combination in incremental fashion
-- v3.03	2022-05-02	Lokesh Devan	- Updated ADJSTR_ENTY_TYP_CD Field to correct typo (PSRN to PRSN)
-- v3.02	2022-03-28	NG				- Added Enterprise Assurance product line supplemental fields.  
-- v3.02	2022-03-21	NG				- Change the LOSS_CNTRY_CD mapping to be CLAIM_SUPP.CLM_ACC_COU_CODE instead								of EVENT.COUNTRY_ID
-- v3.02	2022-03-18	ISchiller		- Updated Loss State Field
-- v3.01	2022-03-17	NG				- Change the LOSS_STATE_CD mapping to be CLAIM.FILING_STATE_ID instead of									EVENT.STATE_ID
-- v3.01	2022-03-04	ISchiller		- No change refresh Only
-- v3.01	2022-02-18	ISChiller		- Updated to v2.70 of abstract
-- v3.00	2022-02-14	ISChiller		- Refactor for new claim exposure table
-- v2.34	2022-02-04	ISchiller		- Reordered some columns to match details in abstract
-- v2.33    2022-02-02  NG				- Added new columns	CLM_ENTRD_DT,CLM_RCVD_DT,SIU_IND_CD,SIU_IND_NM,SIU_ASSIGND_DT,LOSS_CNTRY_NM,changed LOSS_CNTRY_CD to show short code for country
-- v2.32    2021-11-24  NG      		- Correctd joins from Ilanas query leaving join on policy_supp only and making it left join, commented where property condition
-- v2.31    2021-11-05  ISchiller   	- Added filter for property claims for Ilana's base query 
-- v2.30    2021-11-02  NG      		- Replaced loss description from claim_supp table and Loss_pstl_cd and		LOSS_STATE_CD from event table
-- v2.29	2021-10-12	AVS				- Update from Abstraction Layer v2.29
-- v2.16	2021-10-07	AVS				- Added TPA_CLIENT_CD, PREM_EXPOSUR_STATE_CD, PREM_EXPOSUR_STATE_PROV_NM, and PREM_EXPOSUR_CNTRY_CD
-- v2.16    2021-09-30  ISChiller		- Added 3 part table name, added "rmA_main" before each table name,correct timestamp issue (select, cASt and CASE),Added NULL data to fields in abstract,Reformatted query 
-- v2.15	2021-09-24	AVS				- Added Master Company Code and Master Company Name
-- v2.14	2021-08-30	JTC				- added db/schema name to all table references
--										- Added alias name to all table refs
--										- removed use and create view statements
--										- map POL_KEY as null
--										- removed unneeded converts
--										- used safe cast to date and datetime with null traps
--										- revise ROW_UPDT_TS logic
--										- use concat instead of + for concatenation
-- v2.13	2021-08-26	KRB				- Modified to be more Snowflake friendly in format, removed where filter for PR, and created view to ease testing
-- v2.12	2021-08-05	JTC				- added CATSRPH_KEY
-- v2.00	2021-07-25	JTC				- field name changes for abstraction spec v2.03 (not individually commented)
--										- brought up to abstraction spec v2.03
-- 210428t025000 		AZ				- Previous version for abstraction spec v1.43

--CREATE VIEW [ARCH].[vw_DataStore_Claim]
--AS
SELECT 
	"X"."ROW_TYP_NM",
	"X"."SRC_SYS_CD",
	"X"."BUS_UNIT_CD",
	"X"."CLM_KEY",
	"X"."PARENT_CLM_KEY",
	"X"."POL_KEY",
	"X"."LYR_KEY",
	"X"."CATSRPH_KEY",
	DATEADD(ms, 
				10 * (row_number() 
					  over (
							partition by 
							 "X"."CLM_NUM",
							"X"."ORIG_ROW_UPDT_TS" -- ORIG ROW_UPDT_TS
							order by "X"."CLM_KEY"
							)-1
					  ), 
					"X"."ORIG_ROW_UPDT_TS"
				) AS "ROW_UPDT_TS",	
	"X"."CLM_NUM",
	"X"."CLM_REPRTD_DT",
	"X"."PARENT_CLM_NUM",
	"X"."POL_NUM",
	"X"."POL_EFF_DT",
	"X"."POL_ORIG_SRC_CD",
	"X"."LYR_NUM",
	"X"."CLM_LOSS_DT",
	"X"."CLM_LOSS_YR",
	"X"."CLM_STATUS_CD",
	"X"."CLM_STATUS_DESC",
	"X"."CLM_CLOSE_RSN_CD",
	"X"."CLM_CLOSE_RSN_DESC",
	"X"."CLM_CLOSE_TS",
	"X"."CLM_DENIAL_RSN_CD",
	"X"."CLM_DENIAL_RSN_DESC",
	"X"."CLM_DENIAL_RSN_TXT",
	"X"."CLM_DENIAL_TS",
	"X"."LOSS_DESC",
	"X"."LOSS_ADDR_LINE_1",
	"X"."LOSS_ADDR_LINE_2",
	"X"."LOSS_ADDR_LINE_3",
	"X"."LOSS_CITY",
	"X"."LOSS_CNTY",
	"X"."LOSS_STATE_CD",
	"X"."LOSS_STATE_PROV_NM",
	"X"."LOSS_CNTRY_CD",
	"X"."LOSS_CNTRY_NM",
	"X"."LOSS_PSTL_CD",
	"X"."CATSRPH_TYP_CD",
	"X"."CATSRPH_TYP_DESC",
	"X"."CATSRPH_CD_TYP_CD",
	"X"."CATSRPH_CD",
	"X"."CATSRPH_DESC",
	"X"."DNGR_SGNL_CD",
	"X"."DNGR_SGNL_DESC",
	"X"."ADJSTR_CD",
	"X"."ADJSTR_ENTY_TYP_CD",
	"X"."ADJSTR_NM",
	"X"."ADJSTR_PHN_NUM",
	"X"."ADJSTR_EMAIL_ADDR",
	"X"."CLM_OFFICE_CD",
	"X"."CLM_OFFICE_NM",
	"X"."CLM_CATGRY_CD",
	"X"."CLM_CATGRY_DESC",
	"X"."TPA_CD",
	"X"."TPA_ENTY_TYP_CD",
	"X"."TPA_NM",
	"X"."TPA_CLM_NUM",
	"X"."TPA_POL_NUM",
	"X"."TPA_POL_EFF_DT",
	"X"."TPA_POL_ORIG_SRC_CD",
	"X"."CNVRTD_IND",
	"X"."CNVRTD_FROM_SRC_SYS_CD",
	"X"."ISSNG_CMPNY_CD",
	"X"."ISSNG_CMPNY_NM",
	"X"."PREM_EXPOSUR_STATE_CD",
	"X"."PREM_EXPOSUR_STATE_PROV_NM",
	"X"."PREM_EXPOSUR_CNTRY_CD",
	"X"."TPA_CLIENT_CD",
	"X"."TPA_CLIENT_DESC",
	"X"."PREV_TPA_CLM_NUM",
	"X"."TPA_CLM_XFER_DT",
	"X"."TPA_CLM_XFER_FROM_TPA_CD",
	"X"."TPA_CLM_XFER_TYPE_CD",
	"X"."TPA_CLM_XFER_TYPE_DESC",
	"X"."BUS_SCTN_CD",
	"X"."BUS_SCTN_NM",
	"X"."BUS_SUBDIV_CD",
	"X"."BUS_SUBDIV_NM",
	"X"."CLM_ENTRD_DT",
	"X"."CLM_RCVD_DT",
	"X"."SIU_IND",
	"X"."SIU_IND_CD",
	"X"."SIU_IND_NM",
	"X"."SIU_ASSIGND_DT",
	"X"."CLI_REINREP_CD",
	"X"."CLI_REINREP_NM",
	"X"."CLM_MONITOR_FLAG",
	"X"."CLM_MAT_TYP_DESC",
	"X"."CLM_REINSU_FLAG",
	"X"."CLM_REOPENED_DT"
FROM
	(				
		SELECT
		 'Claim' AS "ROW_TYP_NM"
		, 'RMA' AS "SRC_SYS_CD"
		, 'ALL' AS "BUS_UNIT_CD"
		, concat ('RMA-ALL-', CAST("CLAIM"."CLAIM_ID" AS VARCHAR)) AS "CLM_KEY" 
		, NULL AS "POL_KEY"
		, NULL AS "LYR_KEY"
		, "CATASTROPHE"."CATASTROPHE_ROW_ID" AS "CATSRPH_KEY" -- 2021-08-05 JTC:  added field
		,   
			(
				SELECT
					CAST
						(
							CASE 
								WHEN "X"."MAXV" is NULL then NULL 
								else 
								concat(substring("X"."MAXV", 1, 4), '-', substring("X"."MAXV", 5, 2), '-', substring("X"."MAXV", 7, 2), 
								' ', substring("X"."MAXV", 9, 2), ':', substring("X"."MAXV", 11, 2), ':', substring("X"."MAXV", 13, 2))
							END
											AS datetime
									) "X"
								 FROM
									(
										SELECT MAX("VS"."V") AS "MAXV"
											FROM (
												  VALUES (isNULL("CLAIM"."DTTM_RCD_LAST_UPD", '19000101000000')),
														(isNULL("EVENT"."DTTM_RCD_LAST_UPD", '19000101000000')),
														(isNULL("POLICY"."DTTM_RCD_LAST_UPD", '19000101000000')),
														(isNULL("CLAIM_ADJUSTER"."DTTM_RCD_LAST_UPD", '19000101000000')),
														(isNULL("ADJUSTER"."DTTM_RCD_LAST_UPD", '19000101000000')),
														(isNULL("CLAIM_X_PROPERTYLOSS"."DTTM_RCD_LAST_UPD", '19000101000000')),
														(isNULL("PROPERTY_UNIT"."DTTM_RCD_LAST_UPD", '19000101000000'))
												  )  AS "VS"("V")
									) "X"
					) AS "ORIG_ROW_UPDT_TS"
	, NULL AS "PARENT_CLM_KEY"
	, "CLAIM"."CLAIM_NUMBER" AS "CLM_NUM"
	,
	    CASE
			WHEN "CLAIM"."DATE_OF_CLAIM" is NULL THEN NULL
	        ELSE 
				CAST(concat(substring("CLAIM"."DATE_OF_CLAIM", 1, 4), '-', substring("CLAIM"."DATE_OF_CLAIM", 5, 2), '-', substring("CLAIM"."DATE_OF_CLAIM", 7, 2)) AS date)
		END AS "CLM_REPRTD_DT"

	, NULL AS "PARENT_CLM_NUM"
	, "POLICY"."POLICY_NAME" AS "POL_NUM"
	,
       CASE
			WHEN "POLICY"."EFFECTIVE_DATE" is NULL THEN NULL
	        ELSE CAST(concat(substring("POLICY"."EFFECTIVE_DATE", 1, 4), '-', substring("POLICY"."EFFECTIVE_DATE", 5, 2), '-', substring("POLICY"."EFFECTIVE_DATE", 7, 2)) AS date)
		END AS "POL_EFF_DT"
	,
		CASE 
			WHEN "POLICY"."ISSUE_SYSTEM" = 'PIJ' THEN 'Arch' 
			ELSE 'MGA' 
		END AS "POL_ORIG_SRC_CD"
	, NULL AS "LYR_NUM"
	,
		CASE
			WHEN 
					"EVENT"."DATE_OF_EVENT" is NULL then NULL
		        ELSE 
					CAST(concat (substring("EVENT"."DATE_OF_EVENT", 1, 4), '-', 
								 substring("EVENT"."DATE_OF_EVENT", 5, 2), '-', 
								 substring("EVENT"."DATE_OF_EVENT", 7, 2)) AS date)
			END AS "CLM_LOSS_DT" 

	, CAST(substring("EVENT"."DATE_OF_EVENT", 1, 4) AS NUMERIC(38,0)) AS "CLM_LOSS_YR" 
	, "CT_CLM_STA"."SHORT_CODE" AS "CLM_STATUS_CD"
	, "CT_CLM_STA"."CODE_DESC" AS "CLM_STATUS_DESC"
	, "CT_METHD_CLS"."SHORT_CODE" AS "CLM_CLOSE_RSN_CD"
	, "CT_METHD_CLS"."CODE_DESC" AS "CLM_CLOSE_RSN_DESC"
	,
			CASE
				WHEN "CLAIM"."DTTM_CLOSED" is NULL THEN NULL
				ELSE CAST(concat(substring("CLAIM"."DTTM_CLOSED", 1, 4), '-', substring("CLAIM"."DTTM_CLOSED", 5, 2), '-', substring("CLAIM"."DTTM_CLOSED", 7, 2), ' ',  substring("CLAIM"."DTTM_CLOSED", 9, 2), ':', substring("CLAIM"."DTTM_CLOSED", 11, 2), ':', substring("CLAIM"."DTTM_CLOSED", 13, 2)) AS datetime) 
			END AS "CLM_CLOSE_TS"

	, NULL "CLM_DENIAL_RSN_CD"
	, NULL AS "CLM_DENIAL_RSN_DESC"
	, NULL AS "CLM_DENIAL_RSN_TXT"
	,
		CASE
			WHEN "CLAIM"."DTTM_CLOSED" is NULL THEN NULL
			WHEN "CLAIM"."METHOD_CLOSED_CODE" = 2454
		then CAST(concat(substring("CLAIM"."DTTM_CLOSED", 1, 4), '-', substring("CLAIM"."DTTM_CLOSED", 5, 2), '-', substring("CLAIM"."DTTM_CLOSED", 7, 2),
		' ', substring("CLAIM"."DTTM_CLOSED", 9, 2), ':', substring("CLAIM"."DTTM_CLOSED", 11, 2), ':', substring("CLAIM"."DTTM_CLOSED", 13, 2)) as datetime) --
			END AS "CLM_DENIAL_TS"

	,"CLAIM_SUPP"."LOSSDESC_HTML" AS "LOSS_DESC" 
	,"PROPERTY_UNIT"."ADDR1" AS "LOSS_ADDR_LINE_1" 
	,"PROPERTY_UNIT"."ADDR2"  AS "LOSS_ADDR_LINE_2"
	,"PROPERTY_UNIT"."ADDR3" AS "LOSS_ADDR_LINE_3"
	,"PROPERTY_UNIT"."CITY" AS "LOSS_CITY"
	, NULL AS "LOSS_CNTY"-- updated field 
	, "ACC_STATE"."STATE_ID" AS "LOSS_STATE_CD"-- updated field 
	, "ACC_STATE"."STATE_NAME" AS "LOSS_STATE_PROV_NM"-- updated field 
	,"CT_LOSS_CNTRY"."SHORT_CODE" AS "LOSS_CNTRY_CD"--updated to pull COUNTRY code from claim_supp table
	,"CT_LOSS_CNTRY"."CODE_DESC" AS "LOSS_CNTRY_NM"--updated to pull COUNTRY code from claim_supp table
	,"EVENT"."ZIP_CODE" AS "LOSS_PSTL_CD"  
	,"CT_CAT"."SHORT_CODE" AS "CATSRPH_TYP_CD"
	,"CT_CAT"."CODE_DESC" AS "CATSRPH_TYP_DESC"
	,NULL AS "CATSRPH_CD_TYP_CD"
	,"CATASTROPHE"."CAT_NUMBER" AS "CATSRPH_CD"
	,"CATASTROPHE"."DESCRIPTION" AS "CATSRPH_DESC"
    , NULL AS "DNGR_SGNL_CD"
    , NULL AS "DNGR_SGNL_DESC"
    , "ADJUSTER"."ENTITY_ID" AS "ADJSTR_CD"
    , 
		CASE "CT_ADJUSTER_TYP"."SHORT_CODE" 
		WHEN 'IND' 
		THEN 'PRSN' WHEN 'BUS' THEN 'ORG' END AS "ADJSTR_ENTY_TYP_CD"

	, concat ("ADJUSTER"."LAST_NAME", ISNULL(concat(', ', "ADJUSTER"."FIRST_NAME"), '')) AS "ADJSTR_NM"

    , "ADJUSTER"."PHONE1" AS "ADJSTR_PHN_NUM"
    , "ADJUSTER"."EMAIL_ADDRESS" AS "ADJSTR_EMAIL_ADDR"

	, NULL AS "CLM_OFFICE_CD"
	, "CLAIM_SUPP"."CLM_BRANCH_TEXT" AS "CLM_OFFICE_NM"

	, "CLM_CATEGORY"."SHORT_CODE" AS "CLM_CATGRY_CD"
	, "CLM_CATEGORY"."CODE_DESC"  AS "CLM_CATGRY_DESC"

	,"CT_TPA"."SHORT_CODE" AS "TPA_CD"
    , NULL AS "TPA_ENTY_TYP_CD"
    , "CT_TPA"."CODE_DESC" AS "TPA_NM"
    , "CLAIM_SUPP"."CLM_TPA_CN_TEXT" AS "TPA_CLM_NUM"
    , "CLAIM_SUPP"."CLM_TPA_POL_TEXT" AS "TPA_POL_NUM" -- Per Lori, The only location in RMA for the Policy information does not differentiate between TPA / In-House claims.  So the effective date is the same field for both
    ,
	CASE		
		WHEN "POLICY"."EFFECTIVE_DATE" IS NULL THEN NULL
		ELSE CAST(concat (substring("POLICY"."EFFECTIVE_DATE", 1, 4), '-', substring("POLICY"."EFFECTIVE_DATE", 5, 2), '-', substring("POLICY"."EFFECTIVE_DATE", 7, 2)) as date) 
	END AS "TPA_POL_EFF_DT"
	,NULL AS "TPA_POL_ORIG_SRC_CD"
	,
        CASE "CLAIM_SUPP"."CLM_CONVCLM_FLAG"
	            WHEN -1
	            THEN 'Y'
	            ELSE 'N' 
		END AS "CNVRTD_IND"		     
	,
        CASE "CLAIM_SUPP"."CLM_CONVCLM_FLAG"
                WHEN -1 THEN 'AC'
                ELSE '' 
		END AS "CNVRTD_FROM_SRC_SYS_CD"

	, "CT_MC"."SHORT_CODE" "ISSNG_CMPNY_CD"
	, "CT_MC"."CODE_DESC" "ISSNG_CMPNY_NM"
	, "S"."STATE_ID" "PREM_EXPOSUR_STATE_CD"
	, "S"."STATE_NAME" "PREM_EXPOSUR_STATE_PROV_NM"
	,CASE 
		WHEN ISNULL("S"."STATE_ID", '') != '' THEN "S"."COUNTRY_ID" 
		ELSE '' 
	END "PREM_EXPOSUR_CNTRY_CD"
	,"CLAIM_SUPP"."CLM_TPA_CDE_TEXT" AS "TPA_CLIENT_CD"
	, NULL AS "TPA_CLIENT_DESC"
	, NULL AS "PREV_TPA_CLM_NUM"
	, NULL AS "TPA_CLM_XFER_DT"
	, NULL "TPA_CLM_XFER_FROM_TPA_CD"
	, NULL "TPA_CLM_XFER_TYPE_CD"
	, NULL "TPA_CLM_XFER_TYPE_DESC"
	, NULL AS "BUS_SCTN_CD"
	, CLAIM_SUPP.CLM_BUSUNIT_TEXT AS "BUS_SCTN_NM"
	, NULL AS "BUS_SUBDIV_CD"
	, CLAIM_SUPP.CLM_BSUBDIV_TEXT AS "BUS_SUBDIV_NM"	
	,
	    CASE
			WHEN "CLAIM_SUPP"."CLM_DTEENTR_DATE" is NULL THEN NULL
			ELSE CAST(concat(substring("CLAIM_SUPP"."CLM_DTEENTR_DATE", 1, 4), '-', substring("CLAIM_SUPP"."CLM_DTEENTR_DATE", 5, 2), '-', substring("CLAIM_SUPP"."CLM_DTEENTR_DATE", 7, 2)) AS date)
	    END AS "CLM_ENTRD_DT"
	,
	    CASE
			WHEN "CLAIM"."DATE_RPTD_TO_RM" is NULL THEN NULL
			ELSE CAST(concat(substring("CLAIM"."DATE_RPTD_TO_RM", 1, 4), '-', substring("CLAIM"."DATE_RPTD_TO_RM", 5, 2), '-', substring("CLAIM"."DATE_RPTD_TO_RM", 7, 2)) AS date)
		END AS "CLM_RCVD_DT"	
	,
		CASE 
			WHEN "CLAIM_SUPP"."CLM_SIUASS_DATE" is NULL THEN 'N'
			WHEN "CLAIM_SUPP"."CLM_SIUASS_DATE"='' THEN 'N'
			ELSE 'Y' END AS "SIU_IND"
	,"SIU_FRAIND"."SHORT_CODE" AS "SIU_IND_CD"
	,"SIU_FRAIND"."CODE_DESC" AS "SIU_IND_NM"
	,
	    CASE
			WHEN "CLAIM_SUPP"."CLM_SIUASS_DATE" is NULL THEN NULL
			ELSE CAST(concat(substring("CLAIM_SUPP"."CLM_SIUASS_DATE", 1, 4), '-', substring("CLAIM_SUPP"."CLM_SIUASS_DATE", 5, 2), '-', substring("CLAIM_SUPP"."CLM_SIUASS_DATE", 7, 2)) AS date)
		END AS "SIU_ASSIGND_DT"
	,"CLI_REINREP"."SHORT_CODE" AS "CLI_REINREP_CD"
	,"CLI_REINREP"."CODE_DESC" AS "CLI_REINREP_NM"
	, CASE "CLAIM_SUPP"."CLM_MONITOR_FLAG"
	            WHEN -1
	            THEN 'Y'
	            ELSE 'N' 
		END AS "CLM_MONITOR_FLAG"		
	,"CT_MAT"."CODE_DESC" AS "CLM_MAT_TYP_DESC"
	, CASE "CLAIM_SUPP"."CLM_MONITOR_FLAG" WHEN -1 THEN 'Y' ELSE 'N' END AS "CLM_REINSU_FLAG"
	, "CLM_STS_HIST"."LAST_REOPEN_DT" AS "CLM_REOPENED_DT"



	FROM "rmA_main"."dbo"."CLAIM" "CLAIM" (NOLOCK) 
	LEFT JOIN "rmA_main"."dbo"."CLAIM_SUPP" "CLAIM_SUPP" (NOLOCK) ON  "CLAIM"."CLAIM_ID" = "CLAIM_SUPP"."CLAIM_ID" 
	LEFT JOIN "rmA_main"."dbo"."EVENT" "EVENT" (NOLOCK) ON "CLAIM"."EVENT_ID" = "EVENT"."EVENT_ID"
	LEFT JOIN "rmA_main"."dbo"."POLICY" "POLICY" (NOLOCK) ON "POLICY"."POLICY_ID" = "CLAIM"."PRIMARY_POLICY_ID"
	LEFT JOIN "rmA_main"."dbo"."CATASTROPHE" "CATASTROPHE" (NOLOCK) ON "CLAIM"."CATASTROPHE_ROW_ID" = "CATASTROPHE"."CATASTROPHE_ROW_ID"
	LEFT JOIN "rmA_main"."dbo"."CODES_TEXT" "CT_CAT" (NOLOCK) ON "CT_CAT"."CODE_ID" = "CLAIM"."CATASTROPHE_CODE"
	LEFT JOIN "rmA_main"."dbo"."CODES_TEXT" "CT_TPA" (NOLOCK) ON "CT_TPA"."CODE_ID" = "CLAIM_SUPP"."TPA_NAME_CODE"
	LEFT JOIN "rmA_main"."dbo"."CODES_TEXT" "CT_MAT" (NOLOCK) ON "CT_MAT"."CODE_ID" = "CLAIM_SUPP"."CLM_MAT_TYP_CODE"
	LEFT JOIN "rmA_main"."dbo"."CODES_TEXT" "CT_CLM_STA" (NOLOCK) ON "CT_CLM_STA"."CODE_ID" = "CLAIM"."CLAIM_STATUS_CODE"
	LEFT JOIN "rmA_main"."dbo"."CODES_TEXT" "CT_METHD_CLS" (NOLOCK) ON "CT_METHD_CLS"."CODE_ID" = "CLAIM"."METHOD_CLOSED_CODE"
    LEFT JOIN "rmA_main"."dbo"."CODES" "C_MC" (NOLOCK) ON "C_MC"."SHORT_CODE" = "POLICY"."MASTER_COMPANY" AND "C_MC"."TABLE_ID" = 2818 
    LEFT JOIN "rmA_main"."dbo"."CODES_TEXT" "CT_MC" (NOLOCK) ON "CT_MC"."CODE_ID" = "C_MC"."CODE_ID"
	LEFT JOIN "rmA_main"."dbo"."CODES_TEXT" "CLM_CATEGORY" (NOLOCK) ON "CLM_CATEGORY"."CODE_ID" = "CLAIM"."CLAIM_TYPE_CODE"
	LEFT JOIN "rmA_Main"."dbo"."CODES_TEXT" "CLI_REINREP" (NOLOCK) ON "CLI_REINREP"."CODE_ID" = "CLAIM_SUPP"."CLI_REINREP_CODE"
	LEFT JOIN "rmA_main"."dbo"."STATES" "ACC_STATE" (NOLOCK) ON  "ACC_STATE"."STATE_ROW_ID" = "CLAIM".FILING_STATE_ID
	LEFT JOIN 
		(
			SELECT 
				"POLICY_ID", MIN("POLCVG_ROW_ID") "POLCVG_ROW_ID"
			FROM 
				"rmA_main"."dbo"."POLICY_X_CVG_TYPE" "POLICY_X_CVG_TYPE" (NOLOCK) 
			WHERE 
				1=1 
			GROUP BY 
				"POLICY_ID"
		) "POLICY_X_CVG_TYPE_Ctrl" ON "POLICY_X_CVG_TYPE_Ctrl"."POLICY_ID" = "POLICY"."POLICY_ID"		
	LEFT JOIN "rmA_main"."dbo"."POLICY_X_CVG_TYPE" "PXCT" (NOLOCK) ON "PXCT"."POLCVG_ROW_ID" = "POLICY_X_CVG_TYPE_Ctrl"."POLCVG_ROW_ID"
	LEFT JOIN "rmA_main"."dbo"."CVG_TYPE_SUPP" "CTS" ON "CTS"."POLCVG_ROW_ID" = "PXCT"."POLCVG_ROW_ID"
	LEFT JOIN "rmA_main"."dbo"."STATES" "S" ON "S"."STATE_ROW_ID" = "CTS"."POL_PREMSTE_STATE"
	LEFT JOIN "rmA_main"."dbo"."CODES_TEXT" "SIU_FRAIND" ON "SIU_FRAIND"."CODE_ID" = "CLAIM_SUPP"."CLM_FRAIND_CODE"
	LEFT JOIN 
		(
			SELECT 
				"CLAIM_ID",  MIN("ROW_ID") "ROW_ID"
			FROM 
				"rmA_main"."dbo"."CLAIM_X_PROPERTYLOSS" "CLAIM_X_PROPERTYLOSS" (NOLOCK)
			WHERE 
				"INSURED" = -1
			GROUP BY 
				"CLAIM_ID"
		) "CLAIM_X_PROPERTYLOSS_Ctrl" ON "CLAIM_X_PROPERTYLOSS_Ctrl"."CLAIM_ID" = "CLAIM"."CLAIM_ID"
	LEFT JOIN "rmA_main"."dbo"."CLAIM_X_PROPERTYLOSS" "CLAIM_X_PROPERTYLOSS" (NOLOCK) ON "CLAIM_X_PROPERTYLOSS"."ROW_ID" = "CLAIM_X_PROPERTYLOSS_Ctrl"."ROW_ID" 
	LEFT JOIN "rmA_main"."dbo"."PROPERTY_UNIT" "PROPERTY_UNIT" (NOLOCK) ON  "PROPERTY_UNIT"."PROPERTY_ID" = "CLAIM_X_PROPERTYLOSS"."PROPERTY_ID" 
	LEFT JOIN "rmA_main"."dbo"."STATES" "ST_LOSS" (NOLOCK)   ON "EVENT"."STATE_ID" = "ST_LOSS"."STATE_ROW_ID" 
	LEFT JOIN "rmA_main"."dbo"."CODES_TEXT" "CT_LOSS_CNTRY" (NOLOCK) ON CLAIM_SUPP."CLM_ACC_COU_CODE" = "CT_LOSS_CNTRY"."CODE_ID" --updated to pull LOSS COUNTRY from claim_supp table  
	LEFT JOIN "rmA_main"."dbo"."CLAIM_ADJUSTER" "CLAIM_ADJUSTER" (NOLOCK)  ON "CLAIM_ADJUSTER"."CLAIM_ID" = "CLAIM"."CLAIM_ID" AND "CLAIM_ADJUSTER"."CURRENT_ADJ_FLAG" = -1
	LEFT JOIN "rmA_main"."dbo"."ENTITY" "ADJUSTER" (NOLOCK) ON "ADJUSTER"."ENTITY_ID" = "CLAIM_ADJUSTER"."ADJUSTER_EID"
	LEFT JOIN "rmA_main"."dbo"."CODES_TEXT" "CT_ADJUSTER_TYP" (NOLOCK) ON "CT_ADJUSTER_TYP"."CODE_ID" = "ADJUSTER"."NAME_TYPE"
	LEFT JOIN "rmA_main"."dbo"."POLICY_SUPP" "D"  (NOLOCK) 	ON POLICY."POLICY_ID" = "D"."POLICY_ID"
	LEFT JOIN (Select CLAIM_ID, STATUS_CODE, MAX(DATE_STATUS_CHGD) AS LAST_REOPEN_DT from CLAIM_STATUS_HIST where STATUS_CODE = 28328 group by CLAIM_ID, STATUS_CODE) 
		AS "CLM_STS_HIST" ON  "CLAIM"."CLAIM_ID" = "CLM_STS_HIST"."CLAIM_ID"

--[FILING_STATE_ID]
WHERE 1=1 
)"X"
--where "X"."POL_NUM" is not null
	 --AND "D"."POL_BUSUNIT_TEXT" in ('Property', 'E&S Property') 
	 --AND "D"."POL_BSUBDIV_TEXT" in ('E&S Property','Global Property','Onshore Energy - New','Retail Property')
	-- 223513 rw in rmA_Main 20210410102531 on LCL
	--AND "CLAIM"."CLAIM_TYPE_CODE" = 58 -- 58 PR Property -- 20893 rw in rmA_Main 20210410102531 on LCL

/*Filter for the given claim type. This was used to assume the LOB. It could also be based on the policy # on the claim.
this should be filterd on the CLAIM_TYPE_CODE field using the CODE_ID below
Select CODES.CODE_ID, CODES_TEXT.SHORT_CODE,CODES_TEXT.CODE_DESC
From CODES
JOIN CODES_TEXT ON CODES_TEXT.CODE_ID = CODES.CODE_ID
Where TABLE_ID = 1023 AND DELETED_FLAG <> -1

*/

GO


