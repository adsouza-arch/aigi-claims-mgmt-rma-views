USE [rmA_Main]
GO

/****** Object:  View [ARCH].[vw_DataStore_Claimtx]    Script Date: 11/8/2023 9:06:24 PM ******/
DROP VIEW [ARCH].[vw_DataStore_Claimtx]
GO

/****** Object:  View [ARCH].[vw_DataStore_Claimtx]    Script Date: 11/8/2023 9:06:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [ARCH].[vw_DataStore_Claimtx]
AS
/*
-- Modification History:
-- Ver		When		Who				  What
-- v3.12	2023-04-28	NGoel			- updated trns_amt definition for reserve history per fixes of CLI-7099,6998,7162
-- v3.11	2023-02-23	NGoel			-updated trans_subtype_cd to be 'S', trans_status_cd as reserve status and cost_cntnment as reserve type for reserve records
-- v3.10	2022-12-06	NGoel			- Updated trans_amt definition (added a new case) in reserve query to resolve discrepancies for E&S control totals
-- v3.09	2022-11-16	NGoel			- Updated reserve current join logic to exclude rows that has polcvg_loss_row_id=0,also to mark SP for a genuine supplemental payment
-- v3.08	2022-11-14	NGoel			- Updated CLM_EXPOSUR_NUM to include lossrowid same as in exposure view
-- v3.07	2022-09-21	NGoel			- Updated expsoure num to be same as in exposure view, updated supplemental void payment code to be VSP
-- v3.06	2022-08-05 	NGoel			- Updated trans_date to void date for voided funds
-- v3.05    2022-07-05 	NGoel			 - Updated CLM_EXPOSUR_NUM to add coverage key in its definition to match exposure view
-- v3.04   	2022-03-10  ISchiller       - Updated exposure key
-- v3.03    2022-03-10  ISchiller       - Filter for orphaned records added in and escalated to RMA team
-- v3.02    2022-03-04  ISchiller       - Removed filter for orphaned records   
-- v3.01   	2022-02-18  ISchiller       - Updated to abstract version 2.71
-- v3.00    2022-02-15  ISchiller       - Refactored latest RMA Tran version into new exposure hierarchy structure 
-- v2.41    2022-02-10  NGoel              - Updated view further to fix negative outstanding Reserve Balance for EXP1-
											adjusted RH.TRANSACTION_DATE,RH.TRANS_AMT 
-- v2.40    2022-02-08  NG              - Updated view to fix negative outstanding Reserve Balance for EXP1-adjusted TRANSACTION_DATE,RH.TRANS_AMT 
-- v2.39    2022-02-03  NG              - Added following columns with default NULL: PAYMNT_PRODT_CD,PAYMNT_PRODT_DESC,BORDREAU_YR_MO,BORDREAU_DT
-- v2.38    2022-01-24  NG              - Added AZ (EXP1-DCC) codes for cost cntainmnt
-- v2.37    2021-11-29  NG              - Added NA codes for cost cntainmnt, corrected joins from Ilana's query
-- v2.36    2021-11-16  NG              - Added new codes under COST_CNTAINMNT_CD and COST_CNTAINMNT_DESC-DCC codes-BN,CF,DCF,DR,LE1,MV1,SUBR
                                        - Updated file per Ilanas new baseline query with property claims changes
-- v2.35	2021-11-05	ISchiller		- Updated filters for property claim
-- v2.34    2021-10-21  AR              - Removed VIEW creation. 
-- v2.33	2021-10-21	ISchiller		- Added filter for just property claims
-- v2.32    2021-10-21  RMA             - New updated FILE
-- v2.32	2021-10-22	NG				- Add new codes under COST_CNTAINMNT_CD and COST_CNTAINMNT_DESC-AO codes-AX1,MV,DCC codes-LE,LY,EXP,LSSREAC
-- v2.31    2021-10-18  AR              - Converted CTE to Subquery, use concat instead of + for concatenation, ROW_UPDT_TS format fix
-- v2.30	2021-10-12	KRB				- Add transaction status cd & desc
-- v2.29	2021-10-05	AVS				- Add RSV_PAYMNT_TYP_CD (SAL2 / SAL3 / SAL5 / SAL6 / SUBR1/ SUBR2/ SUBR3/ SUBR4/ SUBR5/ SUBR6) = COST_CNTAINMNT_DESC (DCC)
-- v2.29	2021-10-05	AVS				- Add COST_CNTAINMNT_CD and COST_CNTAINMNT_DESC. Modified Outstanding Reserves to Match Abstraction Layer
-- v5.0		2021-09-29	AVS				- Modified Trans Code Mapping
-- v4.0		2021-09-24	AVS				- Modified TransType (latest mapping)
-- v2.12	2021-09-24	AVS				- Modified TransType
-- v2.11    2021-09-22	AVS				- Added Outstanding Reserves and remove filter to accept cancelled claims
-- v2.10    2021-09-20	JTC				- fixed quoted identifiers
-- v2.09    2021-09-17	AVS	            - Added void payment/recovery trans codes & separate transactions
-- v2.08	2021-09-10	JTC				- reformat - double quotes on identifiers
-- v2.06    2021-09-08	JTC	            - Set BUS_UNIT_CD to 'ALL'
-- v2.05    2021-09-07  AR              - Excluded cancelled claims
-- v2.04	2021-08-30	JTC				- Changed claim and claimant key generation to use RMA-ALL- to match claim and claimant queries
-- v2.03	2021-08-30	JTC				- removed temporary filter
-- v2.02	2021-08-30	JTC				- filter records with invalid chars in "RH"."DTTM_RCD_LAST_UPD" (see !!!)
--										- other format changes
-- v2.01	2021-08-30	JTC				- added db/schema name to all table references
--										- Added alias name to all table refs
--										- removed use and create view statements
--										- removed unneeded casts
--										- used safe cast to date and datetime with null traps
--										- revise ROW_UPDT_TS logic
--										- use concat instead of + for concatenation
--										- added double quotes to all dbo references
-- v2.00	2021-08-26	AVS				- Modified to no longer use the _TRACK as this caused missing transactions / mismatch from the UI
*/
select 
		"cteMainQuery"."ROW_TYP_NM"
		, "cteMainQuery"."SRC_SYS_CD"
		, "cteMainQuery"."BUS_UNIT_CD"
		, "cteMainQuery"."CLM_TRANS_KEY"
		, "cteMainQuery"."REINS_PRTCPNT_KEY"
		, "cteMainQuery"."REINS_LYR_KEY"
		, "cteMainQuery"."REINS_AGRMNT_KEY"
		, "cteMainQuery"."PRL_KEY"
		, "cteMainQuery"."COV_KEY"
		, "cteMainQuery"."RSK_KEY"
		, "cteMainQuery"."LYR_KEY"
		, "cteMainQuery"."POL_KEY"
		, "cteMainQuery"."CLM_EXPOSUR_KEY"
		, "cteMainQuery"."CLMNT_KEY"
		, "cteMainQuery"."CLM_KEY"
		, "cteMainQuery"."ROW_UPDT_TS"
		, "cteMainQuery"."ACTVTY_SEQ_NUM"
		, "cteMainQuery"."SRC_SYS_TRANS_ID"
		, "cteMainQuery"."CLM_EXPOSUR_NUM"
		, "cteMainQuery"."CLMNT_NUM"
		, "cteMainQuery"."CLM_NUM"
		, "cteMainQuery"."ASL_CD"
		, "cteMainQuery"."SUBLINE_CD"
		, "cteMainQuery"."CLS_CD"
		, "cteMainQuery"."PRL_CD"	
		, "cteMainQuery"."COV_TYP_CD"
		, "cteMainQuery"."RSK_NUM"
		, "cteMainQuery"."LYR_NUM"
		, "cteMainQuery"."POL_NUM"
		, "cteMainQuery"."POL_EFF_DT"
		, "cteMainQuery"."POL_ORIG_SRC_CD"
		, "cteMainQuery"."TRANS_TS"
		, "cteMainQuery"."ACCTNG_PRD"
		, "cteMainQuery"."ACCTNG_DT"
		, "cteMainQuery"."TRANS_TYP_CD"
		, "cteMainQuery"."TRANS_TYP_DESC"
		, "cteMainQuery"."TRANS_SUBTYP_CD"
		, "cteMainQuery"."TRANS_SUBTYP_DESC"
		, "cteMainQuery"."TRANS_CATGRY_CD"
		, "cteMainQuery"."TRANS_CATGRY_DESC"
		, "cteMainQuery"."RSV_PAYMNT_TYP_CD"
		, "cteMainQuery"."RSV_PAYMNT_TYP_DESC"
		, "cteMainQuery"."NAIC_EXPNS_CD"
		, "cteMainQuery"."NAIC_EXPNS_DESC"
		, "cteMainQuery"."ORIG_CRNCY_CD"
		, CASE 
			WHEN (ISNULL("cteMainQuery"."TRANS_AMT",0) > 0 AND ISNULL("cteMainQuery"."TRANS_TYP_CD", '') = 'P'
			 AND ((ISNULL("cteMainQuery"."TRANS_SUBTYP_CD", '') = 'VP') OR (ISNULL("cteMainQuery"."TRANS_SUBTYP_CD",
			 '') = 'VSP')))
			THEN ("cteMainQuery"."TRANS_AMT"*-1)
			WHEN (ISNULL("cteMainQuery"."TRANS_AMT",0) > 0 AND ISNULL("cteMainQuery"."TRANS_TYP_CD", '') = 'R'
			 AND ISNULL("cteMainQuery"."TRANS_SUBTYP_CD", '') = 'VRCVRY') 
			THEN ("cteMainQuery"."TRANS_AMT"*-1)
		  ELSE "cteMainQuery"."TRANS_AMT" END AS "TRANS_AMT"
		,
			SUM 
				(
				-- Filter for IND, then keeping SUM those
					CASE
					WHEN "TRANS_CATGRY_CD" = 'IND' THEN (
						CASE
							WHEN ("TRANS_SUBTYP_CD" = 'VP' OR "TRANS_SUBTYP_CD" = 'VSP') THEN -CAST("TRANS_AMT" AS
							DECIMAL(12,2))		-- Using double negative here since this should add back to reserve
							WHEN "TRANS_SUBTYP_CD" = 'VRCVRY' THEN -CAST("TRANS_AMT" AS DECIMAL(12,2))	-- Using double negative here since this should add back to reserve
							WHEN "TRANS_TYP_CD" = 'P' THEN -CAST("TRANS_AMT" AS DECIMAL(12,2))		-- Payments should draw reserve down
							ELSE CAST("TRANS_AMT" AS DECIMAL(12,2))
						END)
						ELSE 0 -- Not IND
					END
			) OVER (PARTITION BY "CLM_KEY" ORDER BY "ACTVTY_SEQ_NUM") AS "OUTSTNDNG_INDMNTY_RSV"

		,		
			SUM 
				(
				-- Filter for EXP1 transactions only
					CASE WHEN "TRANS_CATGRY_CD" = 'EXP1' THEN (
						CASE
							WHEN ("TRANS_SUBTYP_CD" = 'VP' OR "TRANS_SUBTYP_CD" = 'VSP')THEN -CAST("TRANS_AMT" AS DECIMAL(12,2))		-- Using double negative here since this should add back to reserve
							WHEN "TRANS_SUBTYP_CD" = 'VRCVRY' THEN -CAST("TRANS_AMT" AS DECIMAL(12,2))	-- Using double negative here since this should add back to reserve
							WHEN "TRANS_TYP_CD" = 'P' THEN -CAST("TRANS_AMT" AS DECIMAL(12,2))		-- Payments should draw reserve down
							ELSE CAST("TRANS_AMT" AS DECIMAL(12,2))
						END)
						ELSE 0 -- Not EXP1
					END
			) OVER (PARTITION BY "CLM_KEY" ORDER BY "ACTVTY_SEQ_NUM") AS "OUTSTNDNG_EXPNS1_RSV"
		,
			SUM (
				-- Filter for EXP2 transactions only
					CASE
					WHEN "TRANS_CATGRY_CD" = 'EXP2' THEN (
						CASE
							WHEN ("TRANS_SUBTYP_CD" = 'VP' OR "TRANS_SUBTYP_CD" = 'VSP') THEN -CAST("TRANS_AMT" AS DECIMAL(12,2))		-- Using double negative here since this should add back to reserve
							WHEN "TRANS_SUBTYP_CD" = 'VRCVRY' THEN -CAST("TRANS_AMT" AS DECIMAL(12,2))	-- Using double negative here since this should add back to reserve
							WHEN "TRANS_TYP_CD" = 'P' THEN -CAST("TRANS_AMT" AS DECIMAL(12,2))		-- Payments should draw reserve down
							ELSE CAST("TRANS_AMT" AS DECIMAL(12,2))
						END)
						ELSE 0 -- Not EXP2
					END
				) OVER (PARTITION BY "CLM_KEY" ORDER BY "ACTVTY_SEQ_NUM") AS "OUTSTNDNG_EXPNS2_RSV"

		,
			SUM (
				-- Filter for MED, then keeping SUM those
				CASE
				WHEN "TRANS_CATGRY_CD" = 'MED' THEN (
					CASE
						WHEN ("TRANS_SUBTYP_CD" = 'VP' OR "TRANS_SUBTYP_CD" = 'VSP') THEN -CAST("TRANS_AMT" AS DECIMAL(12,2))		-- Using double negative here since this should add back to reserve
						WHEN "TRANS_SUBTYP_CD" = 'VRCVRY' THEN -CAST("TRANS_AMT" AS DECIMAL(12,2))	-- Using double negative here since this should add back to reserve
						WHEN "TRANS_TYP_CD" = 'P' THEN -CAST("TRANS_AMT" AS DECIMAL(12,2))		-- Payments should draw reserve down
						ELSE CAST("TRANS_AMT" AS DECIMAL(12,2))
					END)
					ELSE 0 -- Not MED
				END
			) OVER (PARTITION BY "CLM_KEY" ORDER BY "ACTVTY_SEQ_NUM") AS "OUTSTNDNG_MEDICL_RSV"
		
		
		, "cteMainQuery"."COST_CNTAINMNT_CD"
		, "cteMainQuery"."COST_CNTAINMNT_DESC"
		, "cteMainQuery"."ALAE_CD"
		, "cteMainQuery"."ALAE_DESC"
		, "cteMainQuery"."TRANS_STATUS_CD"	
		, "cteMainQuery"."TRANS_STATUS_DESC"
		, "cteMainQuery"."PAYMNT_PRODT_CD"		
		, "cteMainQuery"."PAYMNT_PRODT_DESC"
		, "cteMainQuery"."BORDREAU_YR_MO"
		, "cteMainQuery"."BORDREAU_DT"
		, "cteMainQuery"."DAC_CD"
		, "cteMainQuery"."DAC_DESC"
		
		-- "cteMainQuery"."PROPCLMTXN" test filter for property claims
FROM
(
    SELECT
	--CLAIM_NUMBER, RESERVE_TYPE_CODE,
	"ROW_TYP_NM"
	, "SRC_SYS_CD"
	, "BUS_UNIT_CD"
	, "CLM_TRANS_KEY"
	, "REINS_PRTCPNT_KEY"
	, "REINS_LYR_KEY"
	, "REINS_AGRMNT_KEY"
	, "PRL_KEY"
	, "COV_KEY"
	, "RSK_KEY"
	, "LYR_KEY"
	, "POL_KEY"
	, "CLM_EXPOSUR_KEY"
	, "CLMNT_KEY"
	, "CLM_KEY"
	, "ROW_UPDT_TS"
	,
		ROW_NUMBER() OVER (
				PARTITION BY "A"."CLAIM_ID"
				ORDER BY "A"."TRANSACTION_DATE", "A"."PRIM_KEY" ) As "ACTVTY_SEQ_NUM"
	, "SRC_SYS_TRANS_ID"
	, "CLM_EXPOSUR_NUM"
	, "CLMNT_NUM"
	, "CLM_NUM"
	, "ASL_CD"
	, "SUBLINE_CD"
	, "CLS_CD"
	, "PRL_CD"
	, "COV_TYP_CD"
	, "RSK_NUM"
	, "LYR_NUM"
	, "POL_NUM"
	, "POL_EFF_DT"
	, "POL_ORIG_SRC_CD"
	, "TRANS_TS"
	, "ACCTNG_PRD"
	, "ACCTNG_DT"
	, "TRANS_TYP_CD"
	, "TRANS_TYP_DESC"
	, "TRANS_SUBTYP_CD"
	, "TRANS_SUBTYP_DESC"
	, "TRANS_CATGRY_CD"
	, "TRANS_CATGRY_DESC"
	, "RSV_PAYMNT_TYP_CD"
	, "RSV_PAYMNT_TYP_DESC"
	, "NAIC_EXPNS_CD"
	, "NAIC_EXPNS_DESC"
	, "ORIG_CRNCY_CD"
	,
		CASE
		WHEN ("TRANS_SUBTYP_CD" = 'VP' OR "TRANS_SUBTYP_CD" = 'VSP') THEN -"TRANS_AMT"
		WHEN "TRANS_SUBTYP_CD" = 'VRCVRY' THEN -"TRANS_AMT"
			ELSE "TRANS_AMT"
		END "TRANS_AMT"
	, "COST_CNTAINMNT_CD"
	, "COST_CNTAINMNT_DESC"
	, "ALAE_CD"
    , "ALAE_DESC"
	, "TRANS_STATUS_CD"
	, "TRANS_STATUS_DESC"
    , "PAYMNT_PRODT_CD"
    , "PAYMNT_PRODT_DESC"
    , "BORDREAU_YR_MO"
    , "BORDREAU_DT"
	, "DAC_CD"
	, "DAC_DESC"
	-- "PROPCLMTXN" test filter for prop claims


FROM
(
	SELECT
    --0 VOID_FLAG,
            'ClaimTrans' As "ROW_TYP_NM"
            , 'RMA' As "SRC_SYS_CD"
            , 'ALL' As "BUS_UNIT_CD"
			,
				CASE
					WHEN ISNULL(cast("RC"."RC_ROW_ID" as varchar), '') = '' THEN 'No Reserve'
					ELSE CONCAT ('RMA-ALL-', 'RC-', cast("RC"."RC_ROW_ID" as VARCHAR), '-', 'RH-', cast("RH"."RSV_ROW_ID" as VARCHAR))
				END "CLM_TRANS_KEY"

			, NULL AS "REINS_PRTCPNT_KEY"
			, NULL AS "REINS_LYR_KEY"
			, NULL AS "REINS_AGRMNT_KEY"
            , NULL As "PRL_KEY"
            , NULL As "COV_KEY"
			, NULL As "RSK_KEY"
			, NULL As "LYR_KEY"
			, NULL As "POL_KEY"
			, 
				--CASE
				--	WHEN ISNULL(cast ("CLMNT"."CLAIMANT_EID" as varchar), '') = '' THEN 'No Claimant'
				--	ELSE CONCAT ('RMA-ALL-EXP', concat(CAST("CLAIM"."CLAIM_ID" AS VARCHAR), '-', CAST("CLMNT"."CLAIMANT_EID" AS VARCHAR), '-',
				--				"CLMNT"."CLAIMANT_NUMBER")) 
				--END "CLM_EXPOSUR_KEY"
				CONCAT('RMA-ALL-EXP-',
					(CASE WHEN "CLAIM"."CLAIM_ID" IS NULL or "CLAIM"."CLAIM_ID"=0 OR "CLAIM"."CLAIM_ID"='' THEN 'No Claim' ELSE
						 "CLAIM"."CLAIM_ID" END)
					, '-',
					(CASE WHEN "CLMNT"."CLAIMANT_NUMBER" IS NULL or "CLMNT"."CLAIMANT_NUMBER"=''  THEN '0' ELSE
					"CLMNT"."CLAIMANT_NUMBER" END)
					, '-',
					(CASE WHEN "POLICY_X_UNIT"."STAT_UNIT_NUMBER" IS NOT NULL AND "POLICY_X_UNIT"."STAT_UNIT_NUMBER"<>''  THEN --'0'
					"POLICY_X_UNIT"."STAT_UNIT_NUMBER" 
					ELSE 
					CASE WHEN "POLICY_X_UNIT"."SITE_SEQ_NUMBER" IS NOT NULL AND "POLICY_X_UNIT"."SITE_SEQ_NUMBER"<>'' THEN
					"POLICY_X_UNIT"."SITE_SEQ_NUMBER" ELSE '0' END
					END)
					, '-',
					(CASE WHEN "PXCT"."POLCVG_ROW_ID" IS NULL OR "PXCT"."POLCVG_ROW_ID"='' 
						THEN '0' ELSE "PXCT"."POLCVG_ROW_ID" END)
					,'-',
					(CASE WHEN "RC"."POLCVG_LOSS_ROW_ID" IS NULL OR "RC"."POLCVG_LOSS_ROW_ID"='' 
						THEN '0' ELSE "RC"."POLCVG_LOSS_ROW_ID" END)
					)
					AS "CLM_EXPOSUR_KEY"
           ,
				CASE
					WHEN ISNULL(cast ("CLMNT"."CLAIMANT_EID" as varchar), '') = '' THEN 'No Claimant'
					ELSE CONCAT ('RMA-ALL-', cast("CLAIM"."CLAIM_ID" as VARCHAR), '-', cast("CLMNT"."CLAIMANT_EID" as VARCHAR))
				END "CLMNT_KEY"

			, 
				CONCAT ('RMA-ALL-', cast("CLAIM"."CLAIM_ID" as VARCHAR)) AS "CLM_KEY"
			,
				CAST(CONCAT(
									SUBSTRING("RH"."DTTM_RCD_ADDED", 1, 4) , '-' ,
									SUBSTRING("RH"."DTTM_RCD_ADDED", 5, 2) , '-' ,
									SUBSTRING("RH"."DTTM_RCD_ADDED", 7, 2) , ' ' ,
									CASE WHEN SUBSTRING("RH"."DTTM_RCD_ADDED", 9, 2) = '' THEN '0' ELSE SUBSTRING("RH"."DTTM_RCD_ADDED", 9, 2) END , ':' ,
									CASE
										WHEN SUBSTRING("RH"."DTTM_RCD_ADDED", 11, 2) = '' THEN '00'
										ELSE SUBSTRING("RH"."DTTM_RCD_ADDED", 11, 2) END , ':' ,
									CASE
										WHEN SUBSTRING("RH"."DTTM_RCD_ADDED", 13, 2) = '' THEN '00'
										ELSE SUBSTRING("RH"."DTTM_RCD_ADDED", 13, 2) END) as datetime)   "ROW_UPDT_TS"
			,
					CASE
						WHEN ISNULL(cast("RH"."RSV_ROW_ID" as varchar), '') = '' THEN 'No Reserve History'
						ELSE CONCAT('RH-', cast("RH"."RSV_ROW_ID" as VARCHAR))
					END "SRC_SYS_TRANS_ID"
			--, concat( 'RMA-CLMT-EXP-', "CLMNT"."CLAIMANT_NUMBER") AS "CLM_EXPOSUR_NUM",
			,
			--CASE WHEN "CLMNT"."CLAIMANT_NUMBER" IS NULL THEN 'RMA-CLMT-EXP-99'
			--ELSE (concat( 'RMA-CLMT-EXP-', "CLMNT"."CLAIMANT_NUMBER", '-', "PXCT"."POLCVG_ROW_ID"))
			--END AS "CLM_EXPOSUR_NUM"
					CONCAT('RMA-CLMT-EXP-',
					CASE WHEN "CLMNT"."CLAIMANT_NUMBER" IS NULL OR "CLMNT"."CLAIMANT_NUMBER"='' THEN '0' ELSE
					"CLMNT"."CLAIMANT_NUMBER" END
					, '-',
					CASE WHEN "PXCT"."POLCVG_ROW_ID" IS NULL OR "PXCT"."POLCVG_ROW_ID"='' THEN '0'
					ELSE "PXCT"."POLCVG_ROW_ID" END
					,'-',
					(CASE WHEN "CXL"."CVG_LOSS_ROW_ID" IS NULL OR "CXL"."CVG_LOSS_ROW_ID"='' 
						THEN '0' ELSE "CXL"."CVG_LOSS_ROW_ID" END)
					) AS "CLM_EXPOSUR_NUM"
			,"CLMNT"."CLAIMANT_NUMBER" AS "CLMNT_NUM"
            ,"CLAIM"."CLAIM_NUMBER" AS "CLM_NUM"
			, left("CTS"."POL_ASLOB_TEXT", 3) AS "ASL_CD"
			, "PXCT"."SUB_LINE" AS "SUBLINE_CD"
			, "PXCT"."COVERAGE_CLASS_CODE" AS "CLS_CD"
			, NULL AS "PRL_CD"
			, "CT_COV"."SHORT_CODE" AS "COV_TYP_CD"
			, NULL AS "RSK_NUM"
			, NULL AS "LYR_NUM"
			, "POLICY"."POLICY_NAME" AS "POL_NUM"

			,
			   CASE
					WHEN "POLICY"."EFFECTIVE_DATE" is NULL then NULL
					ELSE CAST(concat(substring("POLICY"."EFFECTIVE_DATE", 1, 4), '-',
					substring("POLICY"."EFFECTIVE_DATE", 5, 2), '-',
					substring("POLICY"."EFFECTIVE_DATE", 7, 2)) AS date)
				END AS "POL_EFF_DT"

			,  NULL AS "POL_ORIG_SRC_CD"
			, 
				CASE
					WHEN "RH"."DATE_ENTERED" is null THEN null
					ELSE cast(concat (substring("RH"."DATE_ENTERED", 1, 4), '-', substring("RH"."DATE_ENTERED", 5, 2), '-', substring("RH"."DATE_ENTERED", 7, 2)) as datetime)
				END AS "TRANS_TS"
            , NULL As "ACCTNG_PRD"
            , NULL As "ACCTNG_DT"
            , 'S' AS "TRANS_TYP_CD"
            , 'Reserves' AS "TRANS_TYP_DESC"
            
            , 'S' As "TRANS_SUBTYP_CD"
            , 'Reserves'  AS "TRANS_SUBTYP_DESC"
            , "RTC"."SHORT_CODE" AS "TRANS_CATGRY_CD"
            , "RTC"."CODE_DESC" AS "TRANS_CATGRY_DESC"
            , "RTC"."SHORT_CODE" AS "RSV_PAYMNT_TYP_CD"
            , "RTC"."CODE_DESC" AS "RSV_PAYMNT_TYP_DESC"
            , NULL  AS "NAIC_EXPNS_CD"
            , NULL  AS "NAIC_EXPNS_DESC"
            , "CURR"."SHORT_CODE" AS "ORIG_CRNCY_CD"
			, 
			   CASE 
				WHEN "RH"."PAID_TOTAL"=0 AND "RH"."INCURRED_AMOUNT"=0 AND "RH"."BALANCE_AMOUNT"=0 AND 
				"RH"."CHANGE_AMOUNT"=-1 THEN "RH"."CHANGE_AMOUNT" --"RH"."RESERVE_AMOUNT"
				WHEN "RH"."PAID_TOTAL"=0 AND "RH"."INCURRED_AMOUNT"=1 AND "RH"."BALANCE_AMOUNT"=1 AND
				"RH"."RESERVE_AMOUNT"=1 AND "RH"."CHANGE_AMOUNT"=1 AND "RC"."BALANCE_AMOUNT"=0 AND 
				"RC"."INCURRED_AMOUNT"=0 AND "RC"."PAID_TOTAL"=0 AND "RC"."RESERVE_AMOUNT"=0 THEN "RH"."INCURRED_AMOUNT" --"RH"."PAID_TOTAL"
				WHEN "RH"."PAID_TOTAL"= "RH"."INCURRED_AMOUNT" AND "RH"."PAID_TOTAL"="RH"."RESERVE_AMOUNT" AND 
				"RH"."BALANCE_AMOUNT"=0 AND "RH"."CHANGE_AMOUNT"=-1 THEN "RH"."CHANGE_AMOUNT"--"RH"."BALANCE_AMOUNT"
				ELSE "RH"."CHANGE_AMOUNT"
			   END AS "TRANS_AMT"
			   --"RH"."CHANGE_AMOUNT" AS "TRANS_AMT"
		,
				CASE 
					WHEN "RH"."ADDED_BY_USER" ='DADDS' THEN "RH"."DATE_ENTERED"
					WHEN "RH"."APPROVER_ID" > 0 AND "RH"."CURRENCY_CONVERSION_DATE" IS NOT NULL THEN "RH"."CURRENCY_CONVERSION_DATE"
					WHEN "RH"."CURRENCY_CONVERSION_DATE" IS NOT NULL AND "RH"."DATE_ENTERED" = SUBSTRING("RH"."CURRENCY_CONVERSION_DATE", 1, 8)  THEN "RH"."DTTM_RCD_ADDED" 
					WHEN "RH"."CURRENCY_CONVERSION_DATE" IS NOT NULL AND "RH"."DTTM_RCD_ADDED" > "RH"."CURRENCY_CONVERSION_DATE" AND "RH"."CHANGE_AMOUNT">0 THEN "RH"."CURRENCY_CONVERSION_DATE"
					ELSE "RH"."DTTM_RCD_ADDED" 
				END AS "TRANSACTION_DATE"
           
            , "RH"."RSV_ROW_ID" AS "PRIM_KEY", "CLAIM"."CLAIM_ID", "CLAIM"."CLAIM_TYPE_CODE"
			,CASE
					WHEN "RTC"."SHORT_CODE" IN ('EXP1','EXP1RE') THEN '1'
					WHEN "RTC"."SHORT_CODE" IN ('EXP2','EXP2RE') THEN '2'
					WHEN "RTC"."SHORT_CODE" IN ('IND','INDRE') THEN '0'
					WHEN "RTC"."SHORT_CODE" IN ('MED','MEDRE') THEN '3'
					ELSE ''
				END AS "COST_CNTAINMNT_CD"
			--, "RTC"."SHORT_CODE" AS "COST_CNTAINMNT_CD"
			, "RTC"."CODE_DESC" As "COST_CNTAINMNT_DESC"
    	    , NULL AS "ALAE_CD"
            , NULL AS "ALAE_DESC"
            , "RES_STATUS"."CODE_ID" As "TRANS_STATUS_CD"
            , "RES_STATUS"."CODE_DESC" As "TRANS_STATUS_DESC"
            , 'RMA' As "PAYMNT_PRODT_CD"
            , 'RMA' As "PAYMNT_PRODT_DESC"
			, NULL As "BORDREAU_YR_MO"
            , NULL As "BORDREAU_DT"
			, "DAC_CD"."SHORT_CODE" AS "DAC_CD"
			, "DAC_CD"."CODE_DESC"  AS "DAC_DESC"

        FROM "rmA_main"."dbo"."CLAIM" "CLAIM" (NOLOCK)
        INNER JOIN "rmA_main"."dbo"."RESERVE_CURRENT" "RC" (NOLOCK) 
			ON "RC"."CLAIM_ID" = "CLAIM"."CLAIM_ID" AND "RC"."POLCVG_LOSS_ROW_ID"<>0
        INNER JOIN "rmA_main"."dbo"."RESERVE_HISTORY" "RH" (NOLOCK) 
			ON "RH"."RC_ROW_ID" = "RC"."RC_ROW_ID"
        LEFT JOIN "rmA_main"."dbo"."CLAIMANT" "CLMNT" (NOLOCK) 
			ON "CLMNT"."CLAIMANT_EID" = "RC"."CLAIMANT_EID" 
			AND "CLMNT"."CLAIM_ID" = "RC"."CLAIM_ID"
        INNER JOIN "rmA_main"."dbo"."CODES_TEXT" "RTC" (NOLOCK) 
			ON "RTC"."CODE_ID" = "RC"."RESERVE_TYPE_CODE"
        INNER JOIN "rmA_main"."dbo"."CODES_TEXT" "CURR" (NOLOCK) 
			ON "CURR"."CODE_ID" = "CLAIM"."CLAIM_CURR_CODE"
   --     INNER JOIN "rmA_main"."dbo"."CODES" "RRC" (NOLOCK) 
			--ON "RRC"."CODE_ID" = "RC"."RESERVE_TYPE_CODE"
   --     LEFT JOIN "rmA_main"."dbo"."CODES_TEXT" "RRCT" (NOLOCK) 
			--ON "RRCT"."CODE_ID" = "RRC"."RELATED_CODE_ID"
		LEFT JOIN "rmA_Main"."dbo"."CODES_TEXT" "RES_STATUS" (NOLOCK) 
			ON "RES_STATUS"."CODE_ID" = "RC"."RES_STATUS_CODE"
-- policy joins

		INNER JOIN "rmA_main"."dbo"."POLICY" "POLICY" (NOLOCK) 
			ON "POLICY"."POLICY_ID" = "CLAIM"."PRIMARY_POLICY_ID"
		LEFT OUTER JOIN "rmA_main"."dbo"."POLICY_SUPP" "POLICY_SUPP" (NOLOCK) 
			ON "POLICY_SUPP"."POLICY_ID" = "POLICY"."POLICY_ID" 
		LEFT JOIN "rmA_main"."dbo"."CODES_TEXT" "DAC_CD" (NOLOCK)
			ON "DAC_CD"."CODE_ID" = "POLICY_SUPP"."POL_DIRASSU_CODE"
		LEFT JOIN
			(
				SELECT
					"POLICY_ID", MIN("POLCVG_ROW_ID") "POLCVG_ROW_ID"
				FROM
					"rmA_Main"."dbo"."POLICY_X_CVG_TYPE" "POLICY_X_CVG_TYPE" (NOLOCK)
				WHERE 1=1
					GROUP BY "POLICY_ID"
			) "POLICY_X_CVG_TYPE_Ctrl" ON "POLICY_X_CVG_TYPE_Ctrl"."POLICY_ID" = "POLICY"."POLICY_ID"

					LEFT JOIN "rmA_main"."dbo"."POLICY_X_CVG_TYPE" "POLICY_X_CVG_TYPE" (NOLOCK) ON "POLICY_X_CVG_TYPE"."POLCVG_ROW_ID" = "POLICY_X_CVG_TYPE_Ctrl"."POLCVG_ROW_ID"
					LEFT JOIN "rmA_main"."dbo"."COVERAGE_X_LOSS" "CXL" (NOLOCK) ON "CXL"."CVG_LOSS_ROW_ID" = "RC".POLCVG_LOSS_ROW_ID
					LEFT JOIN "rmA_main"."dbo"."POLICY_X_CVG_TYPE" "PXCT" (NOLOCK) ON "PXCT"."POLCVG_ROW_ID" = "CXL"."POLCVG_ROW_ID"
					LEFT JOIN "rmA_main"."dbo"."POLICY_X_UNIT" "POLICY_X_UNIT" (NOLOCK) ON "POLICY_X_UNIT".POLICY_UNIT_ROW_ID=
					"PXCT"."POLICY_UNIT_ROW_ID"
					LEFT JOIN "rmA_main"."dbo"."CVG_TYPE_SUPP" "CTS" ON "CTS"."POLCVG_ROW_ID" = "PXCT"."POLCVG_ROW_ID"		
					LEFT JOIN "rmA_main"."dbo"."CODES_TEXT" "CT_COV" (NOLOCK) ON "CT_COV"."CODE_ID" = "PXCT"."COVERAGE_TYPE_CODE"


	
        WHERE
            1 = 1
			--AND "D"."POL_BUSUNIT_TEXT" in ('Property', 'E&S Property') 
			--AND "D"."POL_BSUBDIV_TEXT" in ('E&S Property','Global Property','Onshore Energy - New','Retail Property')
            --AND "C"."CLAIM_STATUS_CODE" <> 28323			--No need to remove Cancelled Claim
		-- Filter for orphan records 
			--AND "CLMNT"."CLAIMANT_EID" = "RC"."CLAIMANT_EID"

        UNION ALL

        SELECT
    --F.VOID_FLAG,
            'ClaimTrans' AS "ROW_TYP_NM"
            , 'RMA' AS "SRC_SYS_CD"
            , 'ALL' AS "BUS_UNIT_CD"
            ,
				CASE
					WHEN ISNULL(cast("FTS"."SPLIT_ROW_ID" as varchar), '') = '' THEN 'No Funds'
					ELSE CONCAT ('RMA-ALL-', 'RC-', cast("RC"."RC_ROW_ID" as VARCHAR), '-', 'FTS-', cast("FTS"."SPLIT_ROW_ID" as VARCHAR),
					CASE "FUNDS"."VOID_FLAG"
						WHEN -1 THEN '-V'
						ELSE ''
                END ) END "CLM_TRANS_KEY"

			, NULL AS "REINS_PRTCPNT_KEY"
			, NULL AS "REINS_LYR_KEY"
			, NULL AS "REINS_CNTRCT_KEY"
            , NULL As "PRL_KEY"
            , NULL As "COV_KEY"
			, NULL As "RSK_KEY"
			, NULL AS "LYR_KEY"
			, NULL AS "POL_KEY"
			,
				--CASE
				--	WHEN ISNULL(cast ("CLMNT"."CLAIMANT_EID" as varchar), '') = '' THEN 'No Claimant'
				--	ELSE CONCAT ('RMA-ALL-', concat(CAST("CLMNT"."CLAIM_ID" AS VARCHAR), '-', CAST("CLMNT"."CLAIMANT_EID" AS VARCHAR), '-',
				--				"CLMNT"."CLAIMANT_NUMBER")) 
				--END "CLM_EXPOSUR_KEY"
								CONCAT('RMA-ALL-EXP-',
					(CASE WHEN "CLAIM"."CLAIM_ID" IS NULL or "CLAIM"."CLAIM_ID"=0 OR "CLAIM"."CLAIM_ID"='' THEN 'No Claim' ELSE
						 "CLAIM"."CLAIM_ID" END)
					, '-',
					(CASE WHEN "CLMNT"."CLAIMANT_NUMBER" IS NULL or "CLMNT"."CLAIMANT_NUMBER"=''  THEN '0' ELSE
					"CLMNT"."CLAIMANT_NUMBER" END)
					, '-',
					(CASE WHEN "POLICY_X_UNIT"."STAT_UNIT_NUMBER" IS NOT NULL AND "POLICY_X_UNIT"."STAT_UNIT_NUMBER"<>''  THEN --'0'
					"POLICY_X_UNIT"."STAT_UNIT_NUMBER" 
					ELSE 
					CASE WHEN "POLICY_X_UNIT"."SITE_SEQ_NUMBER" IS NOT NULL AND "POLICY_X_UNIT"."SITE_SEQ_NUMBER"<>'' THEN
					"POLICY_X_UNIT"."SITE_SEQ_NUMBER" ELSE '0' END
					END)
					, '-',
					(CASE WHEN "PXCT"."POLCVG_ROW_ID" IS NULL OR "PXCT"."POLCVG_ROW_ID"='' 
						THEN '0' ELSE "PXCT"."POLCVG_ROW_ID" END)
					,'-',
					(CASE WHEN "RC"."POLCVG_LOSS_ROW_ID" IS NULL OR "RC"."POLCVG_LOSS_ROW_ID"='' 
						THEN '0' ELSE "RC"."POLCVG_LOSS_ROW_ID" END)
					)
					AS "CLM_EXPOSUR_KEY"
           ,
				CASE
					WHEN ISNULL(cast("CLMNT"."CLAIMANT_EID" as varchar), '') = '' THEN 'No Claimant'
					ELSE CONCAT ('RMA-ALL-', cast("CLMNT"."CLAIM_ID" as VARCHAR), '-', cast("CLMNT"."CLAIMANT_EID" as VARCHAR)) END "CLMNT_KEY"
            , CONCAT ('RMA-ALL-', cast("CLAIM"."CLAIM_ID" as VARCHAR)) AS "CLM_KEY"
			,
				CAST(CONCAT( SUBSTRING("FUNDS"."DTTM_RCD_LAST_UPD", 1, 4) , '-' , SUBSTRING("FUNDS"."DTTM_RCD_LAST_UPD", 5, 2) , '-' , SUBSTRING("FUNDS"."DTTM_RCD_LAST_UPD", 7, 2) , ' ',
				CASE 
					WHEN SUBSTRING("FUNDS"."DTTM_RCD_LAST_UPD", 9, 2) = '' THEN '0' 
					ELSE SUBSTRING("FUNDS"."DTTM_RCD_LAST_UPD", 9, 2) END , ':' ,
				CASE
					WHEN SUBSTRING("FUNDS"."DTTM_RCD_LAST_UPD", 11, 2) = '' THEN '00'
					ELSE SUBSTRING("FUNDS"."DTTM_RCD_LAST_UPD", 11, 2) END , ':' ,
				CASE
					WHEN SUBSTRING("FUNDS"."DTTM_RCD_LAST_UPD", 13, 2) = '' THEN '00'
					ELSE SUBSTRING("FUNDS"."DTTM_RCD_LAST_UPD", 13, 2) END) as datetime)   
				"ROW_UPDT_TS"      
				,
				CASE
					WHEN ISNULL(cast("FTS"."SPLIT_ROW_ID" as varchar), '') = '' THEN 'No Funds'
					ELSE CONCAT('FTS-', cast("FTS"."SPLIT_ROW_ID" as VARCHAR),
                CASE "FUNDS"."VOID_FLAG"
                    WHEN -1 THEN '-V'
                    ELSE ''
                END)
				 END "SRC_SYS_TRANS_ID"
			--concat( 'RMA-CLMT-EXP-', "CLMNT"."CLAIMANT_NUMBER") AS "CLM_EXPOSUR_NUM",
			,
			--CASE WHEN "CLMNT"."CLAIMANT_NUMBER" IS NULL THEN 'RMA-CLMT-EXP-99'
			--ELSE (concat( 'RMA-CLMT-EXP-', "CLMNT"."CLAIMANT_NUMBER", '-', "PXCT"."POLCVG_ROW_ID"))
			--END AS "CLM_EXPOSUR_NUM"
					CONCAT('RMA-CLMT-EXP-',
					CASE WHEN "CLMNT"."CLAIMANT_NUMBER" IS NULL OR "CLMNT"."CLAIMANT_NUMBER"='' THEN '0' ELSE
					"CLMNT"."CLAIMANT_NUMBER" END
					, '-',
					CASE WHEN "PXCT"."POLCVG_ROW_ID" IS NULL OR "PXCT"."POLCVG_ROW_ID"='' THEN '0'
					ELSE "PXCT"."POLCVG_ROW_ID" END 
					,'-',
					(CASE WHEN "CXL"."CVG_LOSS_ROW_ID" IS NULL OR "CXL"."CVG_LOSS_ROW_ID"='' 
						THEN '0' ELSE "CXL"."CVG_LOSS_ROW_ID" END)
					) AS "CLM_EXPOSUR_NUM"
            , "CLMNT"."CLAIMANT_NUMBER" AS "CLMNT_NUM"
            , "CLAIM"."CLAIM_NUMBER" AS "CLM_NUM"
			, left("CTS"."POL_ASLOB_TEXT", 3) AS "ASL_CD"
			, "PXCT"."SUB_LINE" AS "SUBLINE_CD"
			, "PXCT"."COVERAGE_CLASS_CODE" AS "CLS_CD"
			, NULL AS "PRL_CD"
			, "CT_COV"."SHORT_CODE" AS "COV_TYP_CD"
			, NULL AS "RSK_NUM"
			, NULL AS "LYR_NUM"
			, "POLICY"."POLICY_NAME" AS "POL_NUM"
			,
			   CASE
					WHEN "POLICY"."EFFECTIVE_DATE" is NULL then NULL
					ELSE CAST(concat(substring("POLICY"."EFFECTIVE_DATE", 1, 4), '-',
					substring("POLICY"."EFFECTIVE_DATE", 5, 2), '-',
					substring("POLICY"."EFFECTIVE_DATE", 7, 2)) AS date)
				END AS "POL_EFF_DT"

			, NULL AS "POL_ORIG_SRC_CD"
			,
			CASE
				when "FUNDS"."VOID_DATE" is null or "FUNDS"."VOID_DATE"='' then 
				CASE 
					when "FUNDS"."TRANS_DATE" is null then null
					else
					cast(concat (substring("FUNDS"."TRANS_DATE", 1, 4), '-', substring("FUNDS"."TRANS_DATE", 5, 2), '-', substring("FUNDS"."TRANS_DATE", 7, 2)) as date)
				END
                else cast(concat (substring("FUNDS"."VOID_DATE", 1, 4), '-', substring("FUNDS"."VOID_DATE", 5, 2), '-', substring("FUNDS"."VOID_DATE", 7, 2)) as date)
			END AS "TRANS_TS"
            , NULL As "ACCTNG_PRD"
            , NULL As "ACCTNG_DT"
			,
				CASE
					--WHEN ("FUNDS"."PAYMENT_FLAG" = -1 AND "FUNDS"."VOID_FLAG" = -1) THEN 'VP'
					WHEN "FUNDS"."PAYMENT_FLAG" = -1 THEN 'P'
					--WHEN ("FUNDS"."COLLECTION_FLAG" = -1 AND "FUNDS"."VOID_FLAG" = -1) THEN 'VRCVRY'
					WHEN "FUNDS"."COLLECTION_FLAG" = -1 THEN 'R'
					ELSE ''
				END AS "TRANS_TYP_CD"
            ,
				CASE
					--WHEN ("FUNDS"."PAYMENT_FLAG" = -1 AND "FUNDS"."VOID_FLAG" = -1) THEN 'Voided Payment'
					WHEN "FUNDS"."PAYMENT_FLAG" = -1 THEN 'Payments'
					--WHEN ("FUNDS"."COLLECTION_FLAG" = -1 AND "FUNDS"."VOID_FLAG" = -1) THEN 'Voided Recovery'
					WHEN "FUNDS"."COLLECTION_FLAG" = -1 THEN 'Recovery'
					ELSE ''
				END AS "TRANS_TYP_DESC"
			,
				CASE
					WHEN ("FUNDS"."PAYMENT_FLAG" = -1 AND "FUNDS"."STOP_PAY_FLAG" = -1) THEN 'SC'
					WHEN ("FUNDS"."PAYMENT_FLAG" = -1 AND "FUNDS"."VOID_FLAG" = -1 AND
					"FUNDS"."RES_SUPP_PAYMENT_FLAG" = -1) THEN 'VSP'
					WHEN ("FUNDS"."PAYMENT_FLAG" = -1 AND "FUNDS"."VOID_FLAG" = -1) THEN 'VP'
					WHEN ("FUNDS"."COLLECTION_FLAG" = -1 AND "FUNDS"."VOID_FLAG" = -1) THEN 'VRCVRY'
					WHEN ("FUNDS"."PAYMENT_FLAG" = -1 AND "FUNDS"."FINAL_PAYMENT_FLAG" = -1) THEN 'FP'
					WHEN ("FUNDS"."PAYMENT_FLAG" = -1 AND "FUNDS"."RES_SUPP_PAYMENT_FLAG" = -1 and ("FUNDS"."VOID_FLAG" = 0 OR "FUNDS"."VOID_FLAG" IS NULL)) THEN 'SP'
					WHEN ("FUNDS"."PAYMENT_FLAG" = -1 AND "RC"."IS_FIRST_FINAL" = -1) THEN 'FF'
					WHEN ("FUNDS"."PAYMENT_FLAG" = -1) THEN	'P'																								--'P'
					WHEN ("FUNDS"."COLLECTION_FLAG" = -1) THEN 'R'																								--'RCVRY'
					ELSE ''
			 END AS "TRANS_SUBTYP_CD"

            --CASE WHEN "F"."FINAL_PAYMENT_FLAG" = -1 THEN 'Payment Final' WHEN "FTS"."SUPP_PAYMENT_FLAG" = -1 THEN 'Payment After Close' ELSE ''	END AS "TRANS_SUBTYP_DESC",
            ,
				CASE
					WHEN ("FUNDS"."PAYMENT_FLAG" = -1 AND "FUNDS"."STOP_PAY_FLAG" = -1) THEN 'Stop Pay'
					WHEN ("FUNDS"."PAYMENT_FLAG" = -1 AND "FUNDS"."VOID_FLAG" = -1 AND
					"FUNDS"."RES_SUPP_PAYMENT_FLAG" = -1) THEN 'Void Supplemental Payment'
					WHEN ("FUNDS"."PAYMENT_FLAG" = -1 AND "FUNDS"."VOID_FLAG" = -1) THEN 'Void Payment'
					WHEN ("FUNDS"."COLLECTION_FLAG" = -1 AND "FUNDS"."VOID_FLAG" = -1) THEN 'Void Recovery'
					WHEN ("FUNDS"."PAYMENT_FLAG" = -1 AND "FUNDS"."FINAL_PAYMENT_FLAG" = -1) THEN 'Final Payment  - Close Claim'
					WHEN ("FUNDS"."PAYMENT_FLAG" = -1 AND "FUNDS"."RES_SUPP_PAYMENT_FLAG" = -1) and ("FUNDS"."VOID_FLAG" = 0 OR "FUNDS"."VOID_FLAG" IS NULL) THEN 'Additional / Supplemental Payment - No Reserve Change'
					WHEN ("FUNDS"."PAYMENT_FLAG" = -1 AND "RC"."IS_FIRST_FINAL" = -1) THEN 'First and Final Payment - No Reserve Change'
					WHEN ("FUNDS"."PAYMENT_FLAG" = -1) THEN	'Payment' --NULL
					WHEN ("FUNDS"."COLLECTION_FLAG" = -1) THEN	'Recovery' --NULL 
					ELSE ''
				 END AS "TRANS_SUBTYP_DESC"
            , "RTC"."SHORT_CODE" "TRANS_CATGRY_CD"
            , "RTC"."CODE_DESC" "TRANS_CATGRY_DESC"
            , "TTC"."SHORT_CODE" "RSV_PAYMNT_TYP_CD"
            , "TTC"."CODE_DESC" "RSV_PAYMNT_TYP_DESC"
            , NULL AS "NAIC_EXPNS_CD"
            , NULL AS "NAIC_EXPNS_DESC"
            , "CURR"."SHORT_CODE" AS "ORIG_CRNCY_CD"
            , "FTS"."AMOUNT" AS "TRANS_AMT"
			,
				CASE 
					WHEN "FUNDS"."VOID_FLAG"= -1 THEN "FUNDS"."DTTM_RCD_ADDED"
					WHEN "FUNDS"."VOID_FLAG"= 0 THEN "FUNDS"."DTTM_RCD_LAST_UPD"
				END AS "TRANSACTION_DATE"

            , "FTS"."SPLIT_ROW_ID" AS "PRIM_KEY", "CLAIM"."CLAIM_ID", "CLAIM"."CLAIM_TYPE_CODE"

		
			,
				CASE
					WHEN "TTC"."SHORT_CODE" IN ('ADC1', 'AX','AX1','AYCY', 'BTLFEE', 'BTLIA1', 'CAPHLD', 'CM', 'CX', 'CY', 'CY1', 'CZ', 'ET', 'ET1', 'LSS2', 'LSSAPCC1', 'LSSAPMC', 'LSSINAC', 'LSSINAC1',
												'LSSINCC', 'LSSINCC1', 'LSSINMC', 'LSSINMC1', 'LSSINNC', 'LSSINNC1', 'LSSRECC', 'LSSRECC1', 'LSSREMC', 'LSSREMC1', 'LSSRENC', 'LSSRENC1', 'MISC', 'MISC1',
												'MISC3', 'MISC5', 'MISC6', 'MISC7','MV','MZ', 'MZ1', 'OVERPAY3', 'OVERPAY5', 'OVERPAY6', 'SZ', 'SZ1', 'UNK') THEN '2'
					WHEN "TTC"."SHORT_CODE" IN ('ACC', 'ADC', 'ASSINV', 'AY', 'AY1', 'BN', 'BTLFEE1','BTLIA', 'CF', 'CW', 'CW1', 'DCF', 'DR', 'EXP','EXP3', 'EXP4', 'EZ', 'EZ1', 'IME', 'IME1', 'IZ', 'IZ1','LE', 'LE1', 'LSS1', 'LSSAPLE',
												'LSSAPLE1', 'LSSINAD', 'LSSINAD1', 'LSSINLE1', 'LSSINLE2', 'LSSINPCL','LSSREAC','LSSREAD', 'LSSREAD1', 'LSSRELE1', 'LSSRELE2', 'LSSREPCL', 'LW',
												'LW1', 'LY', 'LZ', 'LZ1', 'MU', 'MU1', 'MV1', 'MW', 'MW1', 'OVERPAY1', 'OVERPAY2', 'PCL', 'REIM2', 'REIM3', 'SIR1', 'SIR2','SY', 'SY1',
												'SALV2', 'SALV3', 'SALV5', 'SALV6', 'SUBR', 'SUBR1','SUBR2', 'SUBR3', 'SUBR4', 'SUBR5', 'SUBR6') THEN '1' 
					WHEN "TTC"."SHORT_CODE" IN ('AZ') AND "RTC"."SHORT_CODE" IN ('EXP1') THEN '1'
					WHEN "TTC"."SHORT_CODE" IN ('AZ') AND "RTC"."SHORT_CODE" IN ('EXP2') THEN '2'											
					WHEN "TTC"."SHORT_CODE" IN ('DED1', 'DED2','DED3','DEDCOL1', 'DEDCOL3','Indemnity','IY','LE2','LW2','LZ2','MISC4','MU2','OVERPAY4','OVERPAY8','REIM1','REIM4','SALV1','SALV8','SUBR7','SUBR8') THEN '0'
					--WHEN "TTC"."SHORT_CODE" IN ('NULL',NULL,'" "','') AND "FTS"."DTTM_RCD_ADDED" < '20170101'  THEN '0'
					WHEN "FTS"."DTTM_RCD_ADDED" < '20170101' and FTS.TRANS_TYPE_CODE=0  THEN '0'
					ELSE ''
				END AS "COST_CNTAINMNT_CD"
            ,
					CASE
					WHEN "TTC"."SHORT_CODE" IN ('ADC1', 'AX','AX1', 'AYCY', 'BTLFEE', 'BTLIA1', 'CAPHLD', 'CM', 'CX', 'CY', 'CY1', 'CZ', 'ET', 'ET1', 'LSS2', 'LSSAPCC1', 'LSSAPMC', 'LSSINAC', 'LSSINAC1',
												'LSSINCC', 'LSSINCC1', 'LSSINMC', 'LSSINMC1', 'LSSINNC', 'LSSINNC1', 'LSSRECC', 'LSSRECC1', 'LSSREMC', 'LSSREMC1', 'LSSRENC', 'LSSRENC1', 'MISC', 'MISC1',
												'MISC3', 'MISC5', 'MISC6', 'MISC7','MV','MZ', 'MZ1', 'OVERPAY3', 'OVERPAY5', 'OVERPAY6', 'SZ', 'SZ1', 'UNK') THEN 'AO'
					WHEN "TTC"."SHORT_CODE" IN ('ACC', 'ADC', 'ASSINV', 'AY', 'AY1', 'BN', 'BTLFEE1', 'BTLIA', 'CF', 'CW', 'CW1', 'DCF', 'DR', 'EXP', 'EXP3', 'EXP4', 'EZ', 'EZ1', 'IME', 'IME1', 'IZ', 'IZ1','LE', 'LE1', 'LSS1', 'LSSAPLE',
												'LSSAPLE1', 'LSSINAD', 'LSSINAD1', 'LSSINLE1', 'LSSINLE2', 'LSSINPCL','LSSREAC','LSSREAD', 'LSSREAD1', 'LSSRELE1', 'LSSRELE2', 'LSSREPCL', 'LW',
												'LW1', 'LY', 'LZ', 'LZ1', 'MU', 'MU1', 'MV1', 'MW', 'MW1', 'OVERPAY1', 'OVERPAY2', 'PCL', 'REIM2', 'REIM3', 'SIR1', 'SIR2','SY', 'SY1',
												'SALV2', 'SALV3', 'SALV5', 'SALV6', 'SUBR', 'SUBR1','SUBR2', 'SUBR3', 'SUBR4', 'SUBR5', 'SUBR6') THEN 'DCC'                
					WHEN "TTC"."SHORT_CODE" IN ('AZ') AND "RTC"."SHORT_CODE" IN ('EXP1') THEN 'DCC'
					WHEN "TTC"."SHORT_CODE" IN ('AZ') AND "RTC"."SHORT_CODE" IN ('EXP2') THEN 'AO'
					WHEN "TTC"."SHORT_CODE" IN ('DED1', 'DED2','DED3','DEDCOL1', 'DEDCOL3','Indemnity','IY','LE2','LW2','LZ2','MISC4','MU2','OVERPAY4','OVERPAY8','REIM1','REIM4','SALV1','SALV8','SUBR7','SUBR8') THEN 'Not Applicable'
					WHEN "FTS"."DTTM_RCD_ADDED" < '20170101' and FTS.TRANS_TYPE_CODE=0  THEN 'Not Applicable'
					ELSE ''
			 END AS "COST_CNTAINMNT_DESC"
            , NULL AS "ALAE_CD"
            , NULL AS "ALAE_DESC"
            , "FUND_STATUS"."CODE_ID" As "TRANS_STATUS_CD"
            , "FUND_STATUS"."CODE_DESC" As "TRANS_STATUS_DESC"
            , 'RMA' As "PAYMNT_PRODT_CD"
            , 'RMA' As "PAYMNT_PRODT_DESC"
            ,NULL As "BORDREAU_YR_MO"
            , NULL As "BORDREAU_DT"
			, "DAC_CD"."SHORT_CODE" AS "DAC_CD"
			, "DAC_CD"."CODE_DESC"  AS "DAC_DESC"

		--	"CLAIM"."CLAIM_TYPE_CODE" AS "PROPCLMTXN" test filter for prop claims

        FROM "rmA_main"."dbo"."CLAIM" "CLAIM" (NOLOCK)
        INNER JOIN "rmA_main"."dbo"."FUNDS" "FUNDS" (NOLOCK) 
			ON "FUNDS"."CLAIM_ID" = "CLAIM"."CLAIM_ID"
        INNER JOIN "rmA_main"."dbo"."FUNDS_TRANS_SPLIT" "FTS" (NOLOCK) 
			ON "FTS"."TRANS_ID" = "FUNDS"."TRANS_ID"
        INNER JOIN "rmA_main"."dbo"."RESERVE_CURRENT" "RC" (NOLOCK) 
			ON "RC"."RC_ROW_ID" = "FTS"."RC_ROW_ID"
        LEFT JOIN "rmA_main"."dbo"."CLAIMANT" "CLMNT" (NOLOCK) 
			ON "CLMNT"."CLAIMANT_EID" = "RC"."CLAIMANT_EID" AND "CLMNT"."CLAIM_ID" = "RC"."CLAIM_ID"
        INNER JOIN "rmA_main"."dbo"."CODES_TEXT" "RTC" (NOLOCK) 
			ON "RTC"."CODE_ID" = "RC"."RESERVE_TYPE_CODE"
        INNER JOIN "rmA_main"."dbo"."CODES_TEXT" "TTC" (NOLOCK) 
			ON "TTC"."CODE_ID" = "FTS"."TRANS_TYPE_CODE"
        INNER JOIN "rmA_main"."dbo"."CODES_TEXT" "CURR" (NOLOCK) 
			ON "CURR"."CODE_ID" = "CLAIM"."CLAIM_CURR_CODE"
        LEFT JOIN "rmA_main"."dbo"."CODES_TEXT" "FUND_STATUS" (NOLOCK) 
			ON "FUND_STATUS"."CODE_ID" = "FUNDS"."STATUS_CODE"
		INNER JOIN "rmA_main"."dbo"."CODES_TEXT" "CT_CTD" (NOLOCK) 
			ON "CT_CTD"."CODE_ID" = "CLAIM"."CLAIM_TYPE_CODE" -- Added for claim type code description
			-- policy joins
		INNER JOIN "rmA_main"."dbo"."POLICY" "POLICY" (NOLOCK) 
			ON "POLICY"."POLICY_ID" = "CLAIM"."PRIMARY_POLICY_ID"
		LEFT OUTER JOIN "rmA_main"."dbo"."POLICY_SUPP" "POLICY_SUPP" (NOLOCK) 
			ON "POLICY_SUPP"."POLICY_ID" = "POLICY"."POLICY_ID" 
		LEFT JOIN "rmA_main"."dbo"."CODES_TEXT" "DAC_CD" (NOLOCK)
			ON "DAC_CD"."CODE_ID" = "POLICY_SUPP"."POL_DIRASSU_CODE"
		LEFT JOIN
			(
				SELECT
					"POLICY_ID", MIN("POLCVG_ROW_ID") "POLCVG_ROW_ID"
				FROM
					"rmA_Main"."dbo"."POLICY_X_CVG_TYPE" "POLICY_X_CVG_TYPE" (NOLOCK)
				WHERE 1=1
					GROUP BY "POLICY_ID"
			) "POLICY_X_CVG_TYPE_Ctrl" ON "POLICY_X_CVG_TYPE_Ctrl"."POLICY_ID" = "POLICY"."POLICY_ID"

					LEFT JOIN "rmA_main"."dbo"."POLICY_X_CVG_TYPE" "POLICY_X_CVG_TYPE" (NOLOCK) ON "POLICY_X_CVG_TYPE"."POLCVG_ROW_ID" = "POLICY_X_CVG_TYPE_Ctrl"."POLCVG_ROW_ID"
					LEFT JOIN "rmA_main"."dbo"."COVERAGE_X_LOSS" "CXL" (NOLOCK) ON "CXL"."CVG_LOSS_ROW_ID" = "RC".POLCVG_LOSS_ROW_ID
					LEFT JOIN "rmA_main"."dbo"."POLICY_X_CVG_TYPE" "PXCT" (NOLOCK) ON "PXCT"."POLCVG_ROW_ID" = "CXL"."POLCVG_ROW_ID"
					LEFT JOIN "rmA_main"."dbo"."POLICY_X_UNIT" "POLICY_X_UNIT" (NOLOCK) ON "POLICY_X_UNIT".POLICY_UNIT_ROW_ID=
					"PXCT"."POLICY_UNIT_ROW_ID"
					LEFT JOIN "rmA_main"."dbo"."CVG_TYPE_SUPP" "CTS" ON "CTS"."POLCVG_ROW_ID" = "PXCT"."POLCVG_ROW_ID"		
					LEFT JOIN "rmA_main"."dbo"."CODES_TEXT" "CT_COV" (NOLOCK) ON "CT_COV"."CODE_ID" = "PXCT"."COVERAGE_TYPE_CODE"

        WHERE 1 = 1
	--AND "C"."CLAIM_STATUS_CODE" <> 28323			--No need to remove Cancelled Claim
		--AND "D"."POL_BUSUNIT_TEXT" in ('Property', 'E&S Property') 
		--AND "D"."POL_BSUBDIV_TEXT" in ('E&S Property','Global Property','Onshore Energy - New','Retail Property')
		-- filter for orphan records 
		--AND "CLMNT"."CLAIMANT_EID" = "RC"."CLAIMANT_EID"
		
        UNION ALL

        /*
            To Create Non-Voided Row
            Fetching only voided transaction and reversing it to show non voided ones.
        */
        SELECT
    --F.VOID_FLAG,
           'ClaimTrans' AS "ROW_TYP_NM"
           , 'RMA' AS "SRC_SYS_CD"
           , 'ALL' AS "BUS_UNIT_CD"
           , 
				CASE
					WHEN ISNULL(cast("FTS"."SPLIT_ROW_ID" as varchar), '') = '' THEN 'No Funds'
					ELSE CONCAT ('RMA-ALL-', 'RC-', cast("RC"."RC_ROW_ID" as VARCHAR), '-', 'FTS-', cast("FTS"."SPLIT_ROW_ID" as VARCHAR), '') 
				END "CLM_TRANS_KEY"
			, NULL AS "REINS_PRTCPNT_KEY"
			, NULL AS "REINS_LYR_KEY"
			, NULL AS "REINS_CNTRCT_KEY"
            , NULL As "PRL_KEY"
            , NULL As "COV_KEY"
			, NULL AS "RISK_KEY"
			, NULL AS "LYR_KEY"
			, NULL AS "POL_KEY"
			,
				--CASE
				--	WHEN ISNULL(cast ("CLMNT"."CLAIMANT_EID" as varchar), '') = '' THEN 'No Claimant'
				--	ELSE CONCAT ('RMA-ALL-', concat(CAST("CLMNT"."CLAIM_ID" AS VARCHAR), '-', CAST("CLMNT"."CLAIMANT_EID" AS VARCHAR), '-',
				--				"CLMNT"."CLAIMANT_NUMBER")) 
				--END "CLM_EXPOSUR_KEY"
				CONCAT('RMA-ALL-EXP-',
					(CASE WHEN "CLAIM"."CLAIM_ID" IS NULL or "CLAIM"."CLAIM_ID"=0 OR "CLAIM"."CLAIM_ID"='' THEN 'No Claim' ELSE
						 "CLAIM"."CLAIM_ID" END)
					, '-',
					(CASE WHEN "CLMNT"."CLAIMANT_NUMBER" IS NULL or "CLMNT"."CLAIMANT_NUMBER"=''  THEN '0' ELSE
					"CLMNT"."CLAIMANT_NUMBER" END)
					, '-',
					(CASE WHEN "POLICY_X_UNIT"."STAT_UNIT_NUMBER" IS NOT NULL AND "POLICY_X_UNIT"."STAT_UNIT_NUMBER"<>''  THEN --'0'
					"POLICY_X_UNIT"."STAT_UNIT_NUMBER" 
					ELSE 
					CASE WHEN "POLICY_X_UNIT"."SITE_SEQ_NUMBER" IS NOT NULL AND "POLICY_X_UNIT"."SITE_SEQ_NUMBER"<>'' THEN
					"POLICY_X_UNIT"."SITE_SEQ_NUMBER" ELSE '0' END
					END)
					, '-',
					(CASE WHEN "PXCT"."POLCVG_ROW_ID" IS NULL OR "PXCT"."POLCVG_ROW_ID"='' 
						THEN '0' ELSE "PXCT"."POLCVG_ROW_ID" END)
					,'-',
					(CASE WHEN "RC"."POLCVG_LOSS_ROW_ID" IS NULL OR "RC"."POLCVG_LOSS_ROW_ID"='' 
						THEN '0' ELSE "RC"."POLCVG_LOSS_ROW_ID" END)
					)
					AS "CLM_EXPOSUR_KEY"
			,
				CASE
					WHEN ISNULL(cast("CLMNT"."CLAIMANT_EID" as varchar), '') = '' THEN 'No Claimant'
					ELSE CONCAT ('RMA-ALL-', cast("CLMNT"."CLAIM_ID" as VARCHAR), '-', cast("CLMNT"."CLAIMANT_EID" as VARCHAR)) 
				END "CLMNT_KEY"
            , CONCAT ('RMA-ALL-', cast("CLAIM"."CLAIM_ID" as VARCHAR)) AS "CLM_KEY"
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
				"ROW_UPDT_TS"
			,
				CASE
					WHEN ISNULL(cast("FTS"."SPLIT_ROW_ID" as varchar), '') = '' THEN 'No Funds'
					ELSE CONCAT('FTS-', CAST("FTS"."SPLIT_ROW_ID" as VARCHAR), '')
				END "SRC_SYS_TRANS_ID"
			--concat( 'RMA-CLMT-EXP-', "CLMNT"."CLAIMANT_NUMBER") AS "CLM_EXPOSUR_NUM",
			,
			--CASE WHEN "CLMNT"."CLAIMANT_NUMBER" IS NULL THEN 'RMA-CLMT-EXP-99'
			--ELSE (concat( 'RMA-CLMT-EXP-', "CLMNT"."CLAIMANT_NUMBER", '-', "PXCT"."POLCVG_ROW_ID"))
			--END AS "CLM_EXPOSUR_NUM"
					CONCAT('RMA-CLMT-EXP-',
					CASE WHEN "CLMNT"."CLAIMANT_NUMBER" IS NULL OR "CLMNT"."CLAIMANT_NUMBER"='' THEN '0' ELSE
					"CLMNT"."CLAIMANT_NUMBER" END
					, '-',
					CASE WHEN "PXCT"."POLCVG_ROW_ID" IS NULL OR "PXCT"."POLCVG_ROW_ID"='' THEN '0'
					ELSE "PXCT"."POLCVG_ROW_ID" END
					,'-',
					(CASE WHEN "CXL"."CVG_LOSS_ROW_ID" IS NULL OR "CXL"."CVG_LOSS_ROW_ID"='' 
						THEN '0' ELSE "CXL"."CVG_LOSS_ROW_ID" END)
					) AS "CLM_EXPOSUR_NUM"
            , "CLMNT"."CLAIMANT_NUMBER" AS "CLMNT_NUM"
            , "CLAIM"."CLAIM_NUMBER" AS "CLM_NUM"
			, left("CTS"."POL_ASLOB_TEXT", 3) AS "ASL_CD"
			, "PXCT"."SUB_LINE" AS "SUBLINE_CD"
			, "PXCT"."COVERAGE_CLASS_CODE" AS "CLS_CD"
			, NULL AS "PRL_CD"
			, "CT_COV"."SHORT_CODE" AS "COV_TYP_CD"
			, NULL AS "RSK_NUM"
			, NULL AS "LYR_NUM"
			, "POLICY"."POLICY_NAME" AS "POL_NUM"
			,
			   CASE
					WHEN "POLICY"."EFFECTIVE_DATE" is NULL then NULL
					ELSE CAST(concat(substring("POLICY"."EFFECTIVE_DATE", 1, 4), '-',
					substring("POLICY"."EFFECTIVE_DATE", 5, 2), '-',
					substring("POLICY"."EFFECTIVE_DATE", 7, 2)) AS date)
				END AS "POL_EFF_DT"

			, NULL AS "POL_ORIG_SRC_CD"

			,
				CASE
					when "FUNDS"."TRANS_DATE" is null then null
					else cast(concat (substring("FUNDS"."TRANS_DATE", 1, 4), '-', substring("FUNDS"."TRANS_DATE", 5, 2), '-', substring("FUNDS"."TRANS_DATE", 7, 2)) as date)
				END AS "TRANS_TS"
            , NULL As "ACCTNG_PRD"
            , NULL As "ACCTNG_DT"
			,
				CASE
					--WHEN ("FUNDS"."PAYMENT_FLAG" = -1 AND "FUNDS"."VOID_FLAG" = -1) THEN 'VP'
					WHEN "FUNDS"."PAYMENT_FLAG" = -1 THEN 'P'
					--WHEN ("FUNDS"."COLLECTION_FLAG" = -1 AND "FUNDS"."VOID_FLAG" = -1) THEN 'VRCVRY'
					WHEN "FUNDS"."COLLECTION_FLAG" = -1 THEN 'R'
					ELSE ''
				END AS "TRANS_TYP_CD"
			,
				CASE
					--WHEN ("FUNDS"."PAYMENT_FLAG" = -1 AND "FUNDS"."VOID_FLAG" = -1) THEN 'Voided Payment'
					WHEN "FUNDS"."PAYMENT_FLAG" = -1 THEN 'Payments'
					--WHEN ("FUNDS"."COLLECTION_FLAG" = -1 AND "FUNDS"."VOID_FLAG" = -1) THEN 'Voided Recovery'
					WHEN "FUNDS"."COLLECTION_FLAG" = -1 THEN 'Recovery'
					ELSE ''
				END AS "TRANS_TYP_DESC"
			,
				CASE
					WHEN ("FUNDS"."PAYMENT_FLAG" = -1 AND "FUNDS"."FINAL_PAYMENT_FLAG" = -1) THEN 'FP'
					WHEN ("FUNDS"."PAYMENT_FLAG" = -1 AND "FUNDS"."RES_SUPP_PAYMENT_FLAG" = -1 ) THEN 'SP'
					WHEN ("FUNDS"."PAYMENT_FLAG" = -1 AND "RC"."IS_FIRST_FINAL" = -1) THEN 'FF'
					WHEN ("FUNDS"."PAYMENT_FLAG" = -1) THEN	'P' --'P'
					WHEN ("FUNDS"."COLLECTION_FLAG" = -1) THEN 'R' --'RCVRY'
					ELSE ''
			 END AS "TRANS_SUBTYP_CD"
            ,
				CASE
					WHEN ("FUNDS"."PAYMENT_FLAG" = -1 AND "FUNDS"."FINAL_PAYMENT_FLAG" = -1) THEN 'Final Payment  - Close Claim'
					WHEN ("FUNDS"."PAYMENT_FLAG" = -1 AND "FUNDS"."RES_SUPP_PAYMENT_FLAG" = -1)  THEN 'Additional / Supplemental Payment - No Reserve Change'
					WHEN ("FUNDS"."PAYMENT_FLAG" = -1 AND "RC"."IS_FIRST_FINAL" = -1) THEN 'First and Final Payment - No Reserve Change'
					WHEN ("FUNDS"."PAYMENT_FLAG" = -1) THEN	'Payment' --NULL
					WHEN ("FUNDS"."COLLECTION_FLAG" = -1) THEN	'Recovery' --NULL
					ELSE ''
				 END AS "TRANS_SUBTYP_DESC"

			, "RTC"."SHORT_CODE" "TRANS_CATGRY_CD"
			, "RTC"."CODE_DESC" "TRANS_CATGRY_DESC"
            , "TTC"."SHORT_CODE" "RSV_PAYMNT_TYP_CD"
            , "TTC"."CODE_DESC" "RSV_PAYMNT_TYP_DESC"
            , NULL AS "NAIC_EXPNS_CD"
            , NULL AS "NAIC_EXPNS_DESC"
            , "CURR"."SHORT_CODE" AS "ORIG_CRNCY_CD"
            , "FTS"."AMOUNT" AS "TRANS_AMT"
			, "FUNDS"."DTTM_RCD_LAST_UPD" AS "TRANSACTION_DATE"
             , "FTS"."SPLIT_ROW_ID" AS "PRIM_KEY", "CLAIM"."CLAIM_ID", "CLAIM"."CLAIM_TYPE_CODE"
			,
				CASE
					WHEN "TTC"."SHORT_CODE" IN ('ADC1', 'AX','AX1','AYCY','BTLFEE', 'BTLIA1', 'CAPHLD', 'CM', 'CX', 'CY', 'CY1', 'CZ', 'ET', 'ET1', 'LSS2', 'LSSAPCC1', 'LSSAPMC', 'LSSINAC', 'LSSINAC1',
												'LSSINCC', 'LSSINCC1', 'LSSINMC', 'LSSINMC1', 'LSSINNC', 'LSSINNC1', 'LSSRECC', 'LSSRECC1', 'LSSREMC', 'LSSREMC1', 'LSSRENC', 'LSSRENC1', 'MISC', 'MISC1',
												'MISC3', 'MISC5', 'MISC6', 'MISC7','MV','MZ', 'MZ1', 'OVERPAY3', 'OVERPAY5', 'OVERPAY6', 'SZ', 'SZ1', 'UNK') THEN '2'
					WHEN "TTC"."SHORT_CODE" IN ('ACC', 'ADC', 'ASSINV', 'AY', 'AY1', 'BN', 'BTLFEE1', 'BTLIA', 'CF', 'CW', 'CW1', 'DCF', 'DR', 'EXP','EXP3', 'EXP4', 'EZ', 'EZ1', 'IME', 'IME1', 'IZ', 'IZ1','LE', 'LE1', 'LSS1', 'LSSAPLE',
												'LSSAPLE1', 'LSSINAD', 'LSSINAD1', 'LSSINLE1', 'LSSINLE2', 'LSSINPCL','LSSREAC','LSSREAD', 'LSSREAD1', 'LSSRELE1', 'LSSRELE2', 'LSSREPCL', 'LW',
												'LW1', 'LY', 'LZ', 'LZ1', 'MU', 'MU1', 'MV1', 'MW', 'MW1', 'OVERPAY1', 'OVERPAY2', 'PCL', 'REIM2', 'REIM3', 'SIR1', 'SIR2','SY', 'SY1',
												'SALV2', 'SALV3', 'SALV5', 'SALV6', 'SUBR', 'SUBR1','SUBR2', 'SUBR3', 'SUBR4', 'SUBR5', 'SUBR6') THEN '1'
					WHEN "TTC"."SHORT_CODE" IN ('AZ') AND "RTC"."SHORT_CODE" IN ('EXP1') THEN '1'
					WHEN "TTC"."SHORT_CODE" IN ('AZ') AND "RTC"."SHORT_CODE" IN ('EXP2') THEN '2'
					WHEN "TTC"."SHORT_CODE" IN ('DED1', 'DED2','DED3','DEDCOL1', 'DEDCOL3','Indemnity','IY','LE2','LW2','LZ2','MISC4','MU2','OVERPAY4','OVERPAY8','REIM1','REIM4','SALV1','SALV8','SUBR7','SUBR8') THEN '0'
					WHEN "FTS"."DTTM_RCD_ADDED" < '20170101' and FTS.TRANS_TYPE_CODE=0  THEN '0'
					ELSE ''
				END AS "COST_CNTAINMNT_CD"
			, 
				CASE 
					WHEN "TTC"."SHORT_CODE" IN ('ADC1', 'AX','AX1', 'AYCY', 'BTLFEE', 'BTLIA1', 'CAPHLD', 'CM', 'CX', 'CY', 'CY1', 'CZ', 'ET', 'ET1', 'LSS2', 'LSSAPCC1', 'LSSAPMC', 'LSSINAC', 'LSSINAC1',
												'LSSINCC', 'LSSINCC1', 'LSSINMC', 'LSSINMC1', 'LSSINNC', 'LSSINNC1', 'LSSRECC', 'LSSRECC1', 'LSSREMC', 'LSSREMC1', 'LSSRENC', 'LSSRENC1', 'MISC', 'MISC1',
												'MISC3', 'MISC5', 'MISC6', 'MISC7','MV','MZ', 'MZ1', 'OVERPAY3', 'OVERPAY5', 'OVERPAY6', 'SZ', 'SZ1', 'UNK') THEN 'AO'				
					WHEN "TTC"."SHORT_CODE" IN ('ACC', 'ADC', 'ASSINV', 'AY', 'AY1', 'BN', 'BTLFEE1', 'BTLIA', 'CF', 'CW', 'CW1', 'DCF', 'DR', 'EXP', 'EXP3', 'EXP4', 'EZ', 'EZ1', 'IME', 'IME1', 'IZ', 'IZ1','LE', 'LE1', 'LSS1', 'LSSAPLE',
												'LSSAPLE1', 'LSSINAD', 'LSSINAD1', 'LSSINLE1', 'LSSINLE2', 'LSSINPCL','LSSREAC','LSSREAD', 'LSSREAD1', 'LSSRELE1', 'LSSRELE2', 'LSSREPCL', 'LW',
												'LW1', 'LY', 'LZ', 'LZ1', 'MU', 'MU1', 'MV1', 'MW', 'MW1', 'OVERPAY1', 'OVERPAY2', 'PCL', 'REIM2', 'REIM3', 'SIR1', 'SIR2','SY', 'SY1',
												'SALV2', 'SALV3', 'SALV5', 'SALV6', 'SUBR', 'SUBR1','SUBR2', 'SUBR3', 'SUBR4', 'SUBR5', 'SUBR6') THEN 'DCC'
					WHEN "TTC"."SHORT_CODE" IN ('AZ') AND "RTC"."SHORT_CODE" IN ('EXP1') THEN 'DCC'
					WHEN "TTC"."SHORT_CODE" IN ('AZ') AND "RTC"."SHORT_CODE" IN ('EXP2') THEN 'AO'				
					WHEN "TTC"."SHORT_CODE" IN ('DED1', 'DED2','DED3','DEDCOL1', 'DEDCOL3','Indemnity','IY','LE2','LW2','LZ2','MISC4','MU2','OVERPAY4','OVERPAY8','REIM1','REIM4','SALV1','SALV8','SUBR7','SUBR8',NULL,'NULL') THEN 'Not Applicable'
					WHEN "FTS"."DTTM_RCD_ADDED" < '20170101' and FTS.TRANS_TYPE_CODE=0  THEN 'Not Applicable'
					ELSE ''
				END AS "COST_CNTAINMNT_DESC"
            , NULL AS "ALAE_CD"
            , NULL AS "ALAE_DESC"
            , "FUND_STATUS"."CODE_ID" As "TRANS_STATUS_CD"
            , "FUND_STATUS"."CODE_DESC" As "TRANS_STATUS_DESC"
            , 'RMA' As "PAYMNT_PRODT_CD"
            , 'RMA' As "PAYMNT_PRODT_DESC"
            ,NULL As "BORDREAU_YR_MO"
            , NULL As "BORDREAU_DT"
			, "DAC_CD"."SHORT_CODE" AS "DAC_CD"
			, "DAC_CD"."CODE_DESC"  AS "DAC_DESC"
			-- "CLAIM"."CLAIM_TYPE_CODE" AS "PROPCLMTXN" test filter for prop claims

        FROM "rmA_main"."dbo"."CLAIM" "CLAIM" (NOLOCK)
        INNER JOIN "rmA_Main"."dbo"."FUNDS" "FUNDS" (NOLOCK) 
			ON "FUNDS"."CLAIM_ID" = "CLAIM"."CLAIM_ID"
        INNER JOIN "rmA_Main"."dbo"."FUNDS_TRANS_SPLIT" "FTS" (NOLOCK) 
			ON "FTS"."TRANS_ID" = "FUNDS"."TRANS_ID"
        INNER JOIN "rmA_Main"."dbo"."RESERVE_CURRENT" "RC" (NOLOCK) 
			ON "RC"."RC_ROW_ID" = "FTS"."RC_ROW_ID"
        LEFT JOIN "rmA_Main"."dbo"."CLAIMANT" "CLMNT" (NOLOCK) 
			ON "CLMNT"."CLAIMANT_EID" = "RC"."CLAIMANT_EID" AND "CLMNT"."CLAIM_ID" = "RC"."CLAIM_ID"
        INNER JOIN "rmA_Main"."dbo"."CODES_TEXT" "RTC" (NOLOCK) 
			ON "RTC"."CODE_ID" = "RC"."RESERVE_TYPE_CODE"
        INNER JOIN "rmA_Main"."dbo"."CODES_TEXT" "TTC" (NOLOCK) 
			ON "TTC"."CODE_ID" = "FTS"."TRANS_TYPE_CODE"
        INNER JOIN "rmA_main"."dbo"."CODES_TEXT" "CURR" (NOLOCK) 
			ON "CURR"."CODE_ID" = "CLAIM"."CLAIM_CURR_CODE"
        LEFT JOIN "rmA_Main"."dbo"."CODES_TEXT" "FUND_STATUS" (NOLOCK) 
			ON "FUND_STATUS"."CODE_ID" = "FUNDS"."STATUS_CODE"	
		-- policy joins
		INNER JOIN "rmA_main"."dbo"."POLICY" "POLICY" (NOLOCK) 
			ON "POLICY"."POLICY_ID" = "CLAIM"."PRIMARY_POLICY_ID"
		LEFT OUTER JOIN "rmA_main"."dbo"."POLICY_SUPP" "POLICY_SUPP" (NOLOCK) 
			ON "POLICY_SUPP"."POLICY_ID" = "POLICY"."POLICY_ID" 
		LEFT JOIN "rmA_main"."dbo"."CODES_TEXT" "DAC_CD" (NOLOCK)
			ON "DAC_CD"."CODE_ID" = "POLICY_SUPP"."POL_DIRASSU_CODE"

		LEFT JOIN
			(
				SELECT
					"POLICY_ID", MIN("POLCVG_ROW_ID") "POLCVG_ROW_ID"
				FROM
					"rmA_Main"."dbo"."POLICY_X_CVG_TYPE" "POLICY_X_CVG_TYPE" (NOLOCK)
				WHERE 1=1
					GROUP BY "POLICY_ID"
			) "POLICY_X_CVG_TYPE_Ctrl" ON "POLICY_X_CVG_TYPE_Ctrl"."POLICY_ID" = "POLICY"."POLICY_ID"

		LEFT JOIN "rmA_main"."dbo"."POLICY_X_CVG_TYPE" "POLICY_X_CVG_TYPE" (NOLOCK) ON "POLICY_X_CVG_TYPE"."POLCVG_ROW_ID" =
		"POLICY_X_CVG_TYPE_Ctrl"."POLCVG_ROW_ID"
		LEFT JOIN "rmA_main"."dbo"."COVERAGE_X_LOSS" "CXL" (NOLOCK) ON "CXL"."CVG_LOSS_ROW_ID" = "RC".POLCVG_LOSS_ROW_ID
		LEFT JOIN "rmA_main"."dbo"."POLICY_X_CVG_TYPE" "PXCT" (NOLOCK) ON "PXCT"."POLCVG_ROW_ID" = "CXL"."POLCVG_ROW_ID"
		LEFT JOIN "rmA_main"."dbo"."POLICY_X_UNIT" "POLICY_X_UNIT" (NOLOCK) ON "POLICY_X_UNIT".POLICY_UNIT_ROW_ID=
		"PXCT"."POLICY_UNIT_ROW_ID"
		LEFT JOIN "rmA_main"."dbo"."CVG_TYPE_SUPP" "CTS" ON "CTS"."POLCVG_ROW_ID" = "PXCT"."POLCVG_ROW_ID"		
		LEFT JOIN "rmA_main"."dbo"."CODES_TEXT" "CT_COV" (NOLOCK) ON "CT_COV"."CODE_ID" = "PXCT"."COVERAGE_TYPE_CODE"
        WHERE 1 = 1
        AND "FUNDS"."VOID_FLAG" = -1
			-- Filter for orphan records 
		--AND "CLMNT"."CLAIMANT_EID" = "RC"."CLAIMANT_EID"
		--AND "D"."POL_BUSUNIT_TEXT" in ('Property', 'E&S Property') 
		--AND "D"."POL_BSUBDIV_TEXT" in ('E&S Property','Global Property','Onshore Energy - New','Retail Property')
        --AND "C"."CLAIM_STATUS_CODE" <> 28323			--No need to remove Cancelled Claim
    ) A
    WHERE 1 = 1
) "cteMainQuery"
where "cteMainQuery"."POL_NUM" is not null
GO


