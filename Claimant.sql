USE [rmA_Main]
GO

/****** Object:  View [ARCH].[vw_DataStore_Claimant]    Script Date: 11/8/2023 9:07:13 PM ******/
DROP VIEW [ARCH].[vw_DataStore_Claimant]
GO

/****** Object:  View [ARCH].[vw_DataStore_Claimant]    Script Date: 11/8/2023 9:07:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [ARCH].[vw_DataStore_Claimant] 
AS

-- Description: RMA CLAIMANT source abstraction query
--
-- Modification History:
--
-- Ver		WHEN			Who			What
-- v3.03	2022-08-31		Ng		- Merge from ED Source Query (CLM-11210)
-- v3.02	2022-05-20		PaDhole 	- Added Datadd of 10ms to deduplicate values of ROW_UPDT_TS based on natural keys
-- v3.01	2022-03-04		ISchiller	- No change refresh only
-- v3.01	2022-02-18		ISchiller	- Updated to meet 2.71 abstract
-- v3.00	2022-02-14		ISchiller	- Refactored for new claimant exposure query
-- v2.11	2022-02-10		ISchiller	- Update logic for litigation indicator and date to reflect data on litigation screen
-- v2.10	2022-02-08		ISchiller	- Updated claimant country to proper code description
-- v2.09	2022-02-04		ISchiller	- Updated column order
-- v2.08	2022-02-02      NG				- Added new columns LITGTN_IND,LITGTN_ST,SIU_IND,SIU_IND_CD,SIU_IND_NM,SIU_ASSIGND_DT
-- v2.07	2021-11-24      NG				- Fixed claimant count issue coming after merge corrected the join from Ilanals query leaving the join just on policy_supp, commented the property conditions in where clause
-- v2.06	2021-11-16      NG			- Added/Updated filter for property claims from Ilana's base line query
-- v2.05	2021-10-19      NG			- Changed name of column PRL_CD to ARCH_LOSS_TYP_CD and of PRL_DESC to ARCH_LOSS_TYP_DESC,Added ISO_LOSS_TYP_CD,ISO_LOSS_TYP_DESC,TPA_CLMNT_ENTERED_TS,PREV_TPA_CLMNT_CD as null columns,Changed column names for Bureau Line code and description, TPA Claimant Code and Same As Inured Indicator to match the names in spreadsheet
-- v2.05	2021-10-14      NG              	- Added TPA claimant code, same as insured indicator, bureau line code, and bureau line description
-- v2.05	2021-10-07      AVS			- Fixed ASL_CD not coming through on many records
-- v2.05	2021-10-05	ISchiller		- Added fields added for TPA with a null 
-- v2.04	2021-10-01	ISchiller			- Reformatted and removed criteria to exclude cancelled claims
-- v2.03	2021-09-07      AR 				- Excluded cancelled claims
-- v2.02	2021-08-30	JTC				- added db/schema name to all table references
--											- Added aliAS name to all table refs
--											- removed use and create view statements
--											- removed unneeded CASTs
--											- used safe CAST to date and datetime with NULL traps
--											- revise ROW_UPDT_TS logic
--											- use concat instead of + for concatenation
-- v2.01	2021-08-26	KRB				- Modified to be more Snowflake friENDly in format, removed where filter for PR, and created view to eASe testing
-- v2.00	2021-07-25	JTC				- field name changes for abstraction spec v2.03 (not individually commented)
--								- brought up to abstraction spec v2.03
-- 210428t025000 		AZ				- Previous version for abstraction spec v1.43


SELECT
	"X"."ROW_TYP_NM",
	"X"."SRC_SYS_CD",
	"X"."BUS_UNIT_CD",
	"X"."CLMNT_KEY",
	"X"."CLM_KEY",
	"X"."LYR_KEY",
	"X"."PRL_KEY",
	"X"."COV_KEY",
	"X"."POL_KEY",
	DATEADD(ms, 
			10 * (row_number() 
				  over (
						partition by 
							"X"."CLMNT_NUM",
							"X"."CLM_NUM",
							"X".ORIG_ROW_UPDT_TS
						order by "X"."CLMNT_KEY"
						)-1
				  ), 
				"X".ORIG_ROW_UPDT_TS
			) AS "ROW_UPDT_TS", 
	"X"."CLMNT_NUM",
	"X"."CLM_NUM",
	"X"."LYR_NUM",
	"X"."POL_NUM",
	"X"."POL_EFF_DT",
	"X"."POL_ORIG_SRC_CD",
	"X"."CLMNT_ENTY_TYP_CD",
	"X"."CLMNT_NM",
	"X"."CLMNT_FEIN_NUM",
	"X"."CLMNT_ADDR_LINE_1",
	"X"."CLMNT_ADDR_LINE_2",
	"X"."CLMNT_ADDR_LINE_3",
	"X"."CLMNT_CITY",
	"X"."CLMNT_CNTY",
	"X"."CLMNT_STATE_CD",
	"X"."CLMNT_STATE_PROV_NM",
	"X"."CLMNT_PSTL_CD",
	"X"."CLMNT_CNTRY_CD",
	"X"."CLMNT_CNTCT_NM",
	"X"."CLMNT_PHN_NUM",
	"X"."CLMNT_EMAIL_ADDR",
	"X"."CLMNT_STATUS_CD",
	"X"."CLMNT_STATUS_DESC",
	"X"."CLMNT_CLOSE_RSN_CD",
	"X"."CLMNT_CLOSE_RSN_DESC",
	"X"."CLMNT_CLOSE_TS",
	"X"."CLMNT_DENIAL_RSN_CD",
	"X"."CLMNT_DENIAL_RSN_DESC",
	"X"."CLMNT_DENIAL_RSN_TXT",
	"X"."CLMNT_DENIAL_TS",
	"X"."RGN_CD",
	"X"."RGN_NM",
	"X"."COV_TYP_CD",
	"X"."COV_TYP_DESC",
	"X"."COV_BASIS_CD",
	"X"."COV_BASIS_DESC",
	"X"."ARCH_LOSS_TYP_CD",
	"X"."ARCH_LOSS_TYP_DESC",
	"X"."ASL_CD",
	"X"."SUBLINE_CD",
	"X"."CLS_CD",
	"X"."CLS_DESC",
	"X"."PREV_TPA_CLMNT_CD",
	"X"."TPA_CLMNT_CD",
	"X"."TPA_CLMNT_ENTERED_TS",
	"X"."SAME_AS_INSRD_IND",
	"X"."BUREAU_LINE_CD",
	"X"."BUREAU_LINE_DESC",
    	"X"."ISO_LOSS_TYP_CD",
   	"X"."ISO_LOSS_TYP_DESC",
	"X"."LITGTN_IND",
	"X"."LITGTN_DT",
	"X"."SIU_IND",
	"X"."SIU_IND_CD",
	"X"."SIU_IND_NM",
	"X"."SIU_ASSIGND_DT",
	"X"."CAUSE_OF_LOSS_NOTES"

FROM
	(
		SELECT
			'Claimant' AS "ROW_TYP_NM"
			, 'RMA' AS "SRC_SYS_CD"
			, 'ALL' AS "BUS_UNIT_CD"
			, concat ('RMA-ALL-', concat (CAST("CLAIMANT"."CLAIM_ID" AS VARCHAR), '-', CAST("CLAIMANT"."CLAIMANT_EID" AS VARCHAR))) AS "CLMNT_KEY"
			, concat ('RMA-ALL-', CAST("CLAIMANT"."CLAIM_ID" AS VARCHAR)) AS "CLM_KEY"
			, NULL AS "LYR_KEY"
			, NULL AS "PRL_KEY"
			, NULL AS "COV_KEY"
			, NULL AS "POL_KEY"
			,
				(
					SELECT
						CAST
						(
							CASE
								WHEN "X"."MAXV" is NULL then NULL
								ELSE
								concat(substring("X"."MAXV", 1, 4), '-', substring("X"."MAXV", 5, 2), '-', substring("X"."MAXV", 7, 2),
								' ', substring("X"."MAXV", 9, 2), ':', substring("X"."MAXV", 11, 2), ':', substring("X"."MAXV", 13, 2))
							END
							AS datetime
						) "X"
					FROM
					(
						SELECT
							MAX("VS"."V") AS "MAXV"
						FROM
						(
							VALUES
								(isNULL("CLAIM"."DTTM_RCD_LAST_UPD", '19000101000000')),
								(isNULL("CLAIMANT"."DTTM_RCD_LAST_UPD", '19000101000000')),
								(isNULL("EN_CLMNT"."DTTM_RCD_LAST_UPD", '19000101000000')),
								(isNULL("EVENT"."DTTM_RCD_LAST_UPD", '19000101000000')),
								(isNULL("POLICY"."DTTM_RCD_LAST_UPD", '19000101000000')),
								(isNULL("POLICY_X_CVG_TYPE"."DTTM_RCD_LAST_UPD", '19000101000000'))
						) AS "VS"("V")
					) "X"
				) AS "ORIG_ROW_UPDT_TS"
			, "CLAIMANT"."CLAIMANT_NUMBER" AS "CLMNT_NUM"
			, "CLAIM"."CLAIM_NUMBER" AS "CLM_NUM"
			, NULL AS "LYR_NUM"
			, "POLICY"."POLICY_NAME" AS "POL_NUM"
			,
			   CASE
					WHEN "POLICY"."EFFECTIVE_DATE" is NULL THEN NULL
					ELSE CAST(concat(substring("POLICY"."EFFECTIVE_DATE", 1, 4), '-', substring("POLICY"."EFFECTIVE_DATE", 5, 2), '-', substring("POLICY"."EFFECTIVE_DATE", 7, 2)) AS date)
				END AS "POL_EFF_DT"
			, NULL AS "POL_ORIG_SRC_CD"
			, NULL AS "CLMNT_ENTY_TYP_CD"
			, concat ("EN_CLMNT"."LAST_NAME", CASE WHEN ISNULL("EN_CLMNT"."FIRST_NAME", '') = '' then '' ELSE concat(', ', "EN_CLMNT"."FIRST_NAME") END) AS "CLMNT_NM"
			, "EN_CLMNT"."TAX_ID" AS "CLMNT_FEIN_NUM"
			, "EN_CLMNT"."ADDR1" AS "CLMNT_ADDR_LINE_1"
			, "EN_CLMNT"."ADDR2" AS "CLMNT_ADDR_LINE_2"
			, "EN_CLMNT"."ADDR3" AS "CLMNT_ADDR_LINE_3"
			, "EN_CLMNT"."CITY" AS "CLMNT_CITY"
			, "EN_CLMNT"."COUNTY" AS "CLMNT_CNTY"
			, "ST_EN_CLMNT"."STATE_ID" AS "CLMNT_STATE_CD"
			, "ST_EN_CLMNT"."STATE_NAME" AS "CLMNT_STATE_PROV_NM"
			, "EN_CLMNT"."ZIP_CODE" AS "CLMNT_PSTL_CD"
			, "CLMNT_CRTY"."SHORT_CODE" AS "CLMNT_CNTRY_CD"
			, NULL AS "CLMNT_CNTCT_NM"
			, "EN_CLMNT"."PHONE1" AS "CLMNT_PHN_NUM"
			, "EN_CLMNT"."EMAIL_ADDRESS" AS "CLMNT_EMAIL_ADDR"
			, "CT_CLMNT_STA"."SHORT_CODE" AS "CLMNT_STATUS_CD"
			, "CT_CLMNT_STA"."CODE_DESC" AS "CLMNT_STATUS_DESC"
			, "CT_METHD_CLS"."SHORT_CODE" AS "CLMNT_CLOSE_RSN_CD"
			, "CT_METHD_CLS"."CODE_DESC" AS "CLMNT_CLOSE_RSN_DESC"
			,
				CASE
					WHEN "CLAIM"."DTTM_CLOSED" is NULL then NULL
					ELSE
						CAST
							(concat(substring("CLAIM"."DTTM_CLOSED", 1, 4), '-', substring("CLAIM"."DTTM_CLOSED", 5, 2), '-', substring("CLAIM"."DTTM_CLOSED", 7, 2),
							' ', substring("CLAIM"."DTTM_CLOSED", 9, 2), ':', substring("CLAIM"."DTTM_CLOSED", 11, 2), ':', substring("CLAIM"."DTTM_CLOSED", 13, 2)) AS datetime)
					END AS "CLMNT_CLOSE_TS"
			,
				CASE "CLAIM"."METHOD_CLOSED_CODE"
					WHEN 2454 THEN "CT_METHD_CLS"."SHORT_CODE"
				END AS "CLMNT_DENIAL_RSN_CD"
			,
				CASE "CLAIM"."METHOD_CLOSED_CODE"
					WHEN 2454 THEN "CT_METHD_CLS"."CODE_DESC"
					END AS "CLMNT_DENIAL_RSN_DESC"

			, NULL AS "CLMNT_DENIAL_RSN_TXT"
			,
				CASE
					WHEN "CLAIM"."DTTM_CLOSED" is NULL then NULL
					WHEN "CLAIM"."METHOD_CLOSED_CODE" = 2454
					THEN CAST(concat(substring("CLAIM"."DTTM_CLOSED", 1, 4), '-', substring("CLAIM"."DTTM_CLOSED", 5, 2), '-', substring("CLAIM"."DTTM_CLOSED", 7, 2),
					' ', substring("CLAIM"."DTTM_CLOSED", 9, 2), ':', substring("CLAIM"."DTTM_CLOSED", 11, 2), ':', substring("CLAIM"."DTTM_CLOSED", 13, 2)) AS datetime)
				END AS "CLMNT_DENIAL_TS"
	, NULL AS "RGN_CD" 	-- Per Lori, Policy Underwriting Region is in Policy Staging, not in RMA
	, NULL AS "RGN_NM" 	-- "NOTE": for ED.Claimant.COV_TYPE_CODE, RMA COV is with Policy, not with Claimant
	, "CT_COV"."SHORT_CODE" AS "COV_TYP_CD"
	, "CT_COV"."CODE_DESC" AS "COV_TYP_DESC"
	,
		CASE "CLAIM_SUPP"."CLM_CLMDOCC_FLAG"
			WHEN 0 THEN 'CM'
			WHEN -1 THEN 'OCC'
			ELSE '' END AS "COV_BASIS_CD"
	,
		CASE "CLAIM_SUPP"."CLM_CLMDOCC_FLAG"
			WHEN 0 THEN 'Claims Made'
			WHEN -1 THEN 'Occurrence'
			ELSE '' END AS "COV_BASIS_DESC" 	-- Expecting ACT, AOP, WIND, EQ, FLOOD, B&M, CYBER, TRIPRA
	, "CT_PER"."SHORT_CODE" AS "ARCH_LOSS_TYP_CD" 	--changed this name PRL_CD to ARCH_LOSS_TYP_CD, Expecting Actual Peril, All other Perils, Wind, Earthquake, Flookd, Boiler and Machinery, Cyber 
	, "CT_PER"."CODE_DESC" AS "ARCH_LOSS_TYP_DESC" 	----changed this name PRL_DESC to ARCH_LOSS_TYP_DESC, 2021-05-04 JTC: changed mapping. Old: "CLAIM"."POLICY_LOB_CODE"
	, left("CVG_TYPE_SUPP"."POL_ASLOB_TEXT", 3) AS "ASL_CD" -- 2021-05-04 JTC: changed mapping. Old: NULL,Per Lori, this is in Policy Staging, not in RMA
	, "POLICY_X_CVG_TYPE"."SUB_LINE" AS "SUBLINE_CD"
	, "POLICY_X_CVG_TYPE"."COVERAGE_CLASS_CODE" AS "CLS_CD"
	-- Per Lori, RMA does not have the description of the Class Code stored
	, NULL AS "CLS_DESC"
			, NULL AS "PREV_TPA_CLMNT_CD"
			, "CLAIMANT_SUPP"."CLM_TPA_NUM_TEXT" AS "TPA_CLMNT_CD"
			, NULL AS "TPA_CLMNT_ENTERED_TS"
			,
				CASE
					WHEN "POLICY_X_INSURED"."ADD_AS_CLAIMANT"  IS NULL THEN 'N'
					ELSE 'Y'
				END AS "SAME_AS_INSRD_IND"
			, NULL AS "BUREAU_LINE_CD"
			, NULL AS "BUREAU_LINE_DESC"
    	, NULL AS "ISO_LOSS_TYP_CD"
    	, NULL AS "ISO_LOSS_TYP_DESC"
			,
				CASE "CLAIM_SUPP"."CLM_LIT_FLAG"
					WHEN 0 THEN 'N'
					WHEN -1 THEN 'Y'
					ELSE NULL
				END AS "LITGTN_IND"
			,
				CASE
	    WHEN "CLAIM_SUPP"."CLM_LITCDTE_DATE" is NULL THEN NULL
		else CAST(concat(substring("CLAIM_SUPP"."CLM_LITCDTE_DATE", 1, 4), '-',
						substring("CLAIM_SUPP"."CLM_LITCDTE_DATE", 5, 2), '-',
						substring("CLAIM_SUPP"."CLM_LITCDTE_DATE", 7, 2)) AS date)
	    END AS "LITGTN_DT"
			,
				CASE
					WHEN "SIU_FRAIND"."SHORT_CODE" IS NOT NULL OR "CLAIM_SUPP"."CLM_SIUASS_DATE" IS NOT NULL THEN 'Y'
					ELSE 'N'
				END AS "SIU_IND"
				--
		,"SIU_FRAIND"."SHORT_CODE" AS "SIU_IND_CD"
		,"SIU_FRAIND"."CODE_DESC" AS "SIU_IND_NM"
			,
				CASE
					WHEN "CLAIM_SUPP"."CLM_SIUASS_DATE" is NULL then NULL
					ELSE CAST(concat(substring("CLAIM_SUPP"."CLM_SIUASS_DATE", 1, 4), '-',
					substring("CLAIM_SUPP"."CLM_SIUASS_DATE", 5, 2), '-',
					substring("CLAIM_SUPP"."CLM_SIUASS_DATE", 7, 2)) AS date)
				END AS "SIU_ASSIGND_DT"
		, NULL AS "CAUSE_OF_LOSS_NOTES"
			FROM "rmA_Main"."dbo"."CLAIM" "CLAIM" (NOLOCK)
				LEFT JOIN "rmA_Main"."dbo"."CLAIM_SUPP" "CLAIM_SUPP" (NOLOCK) ON "CLAIM"."CLAIM_ID" = "CLAIM_SUPP"."CLAIM_ID"
				LEFT JOIN "rmA_main"."dbo"."EVENT" "EVENT" (NOLOCK) ON "CLAIM"."EVENT_ID" = "EVENT"."EVENT_ID"
				LEFT JOIN "rmA_Main"."dbo"."POLICY" "POLICY" (NOLOCK) ON "POLICY"."POLICY_ID" = "CLAIM"."PRIMARY_POLICY_ID"
				JOIN "rmA_Main"."dbo"."CLAIMANT" "CLAIMANT" (NOLOCK) ON "CLAIMANT"."CLAIM_ID" = "CLAIM"."CLAIM_ID"
				LEFT JOIN "rmA_Main"."dbo"."CLAIMANT_SUPP" "CLAIMANT_SUPP" (NOLOCK) ON "CLAIMANT"."CLAIMANT_ROW_ID" = "CLAIMANT_SUPP"."CLAIMANT_ROW_ID"
				LEFT JOIN "rmA_Main"."dbo"."POLICY_X_INSURED" "POLICY_X_INSURED" (NOLOCK) ON "POLICY_X_INSURED"."POLICY_ID"="POLICY"."POLICY_ID"
					AND "POLICY_X_INSURED"."INSURED_EID"="CLAIMANT"."CLAIMANT_EID"
				LEFT JOIN "rmA_Main"."dbo"."ENTITY" "EN_CLMNT" (NOLOCK) ON "CLAIMANT"."CLAIMANT_EID" = "EN_CLMNT"."ENTITY_ID"
				LEFT JOIN "rmA_Main"."dbo"."ENTITY" "EN_CLMNT_CTRY" (NOLOCK) ON "CLAIMANT"."CLAIMANT_EID" = "EN_CLMNT_CTRY"."ENTITY_ID"
				LEFT JOIN "rmA_Main"."dbo"."CODES_TEXT" "CLMNT_CRTY" (NOLOCK) ON "CLMNT_CRTY"."CODE_ID" = "EN_CLMNT_CTRY"."COUNTRY_CODE"
				LEFT JOIN "rmA_Main"."dbo"."STATES" "ST_EN_CLMNT" (NOLOCK) ON "EN_CLMNT"."STATE_ID" = "ST_EN_CLMNT"."STATE_ROW_ID"
				LEFT JOIN "rmA_Main"."dbo"."CODES_TEXT" "CT_CLMNT_STA" (NOLOCK) ON "CT_CLMNT_STA"."CODE_ID" = "CLAIMANT"."CLAIMANT_STATUS_CODE"
				LEFT JOIN "rmA_Main"."dbo"."CODES_TEXT" "CT_CLMNT_TYP" (NOLOCK) ON "CT_CLMNT_TYP"."CODE_ID" = "CLAIMANT"."CLAIMANT_TYPE_CODE"
				LEFT JOIN "rmA_Main"."dbo"."CODES_TEXT" "CT_METHD_CLS" (NOLOCK) ON "CT_METHD_CLS"."CODE_ID" = "CLAIM"."METHOD_CLOSED_CODE"
				INNER JOIN "rmA_Main"."dbo"."CODES_TEXT" "CT_CTD" (NOLOCK) ON "CT_CTD"."CODE_ID" = "CLAIM"."CLAIM_TYPE_CODE"
				LEFT JOIN "rmA_Main"."dbo"."CODES_TEXT" "SIU_FRAIND" ON "SIU_FRAIND"."CODE_ID" = "CLAIM_SUPP"."CLM_FRAIND_CODE"
		LEFT JOIN
			(
				SELECT
					"LITIGATE_ROW"."CLAIM_ID", MIN("LITIGATE_ROW"."LITIGATION_ROW_ID") AS "MIN_ROW"
				FROM
					"rmA_Main"."dbo"."CLAIM_X_LITIGATION" "LITIGATE_ROW" (NOLOCK)
				WHERE 1=1
				GROUP BY "LITIGATE_ROW"."CLAIM_ID"
			)"LITIGATION" ON "LITIGATION"."CLAIM_ID" = "CLAIM"."CLAIM_ID"
		LEFT JOIN
			(
				SELECT
					"SUIT_DATE"."CLAIM_ID", MIN(CAST(concat(substring("SUIT_DATE"."MATTER_CREATION_DATE", 1, 4), '-',
					substring("SUIT_DATE"."MATTER_CREATION_DATE", 5, 2), '-',
					substring("SUIT_DATE"."MATTER_CREATION_DATE", 7, 2)) AS date)) AS "MATTER_DATE"
				FROM
					"rmA_Main"."dbo"."CLAIM_X_LITIGATION" "SUIT_DATE" (NOLOCK)
				WHERE 1=1
				GROUP BY "SUIT_DATE"."CLAIM_ID"
			)"LITIGATE_DATE" ON "LITIGATE_DATE"."CLAIM_ID" = "CLAIM"."CLAIM_ID"
				LEFT JOIN
					(
						SELECT
							"POLICY_ID", MIN("POLCVG_ROW_ID") "POLCVG_ROW_ID"
						FROM
							"rmA_Main"."dbo"."POLICY_X_CVG_TYPE" "POLICY_X_CVG_TYPE" (NOLOCK)
						WHERE
							1=1
						GROUP BY
							"POLICY_ID"
					) "POLICY_X_CVG_TYPE_Ctrl" ON "POLICY_X_CVG_TYPE_Ctrl"."POLICY_ID" = "POLICY"."POLICY_ID"
				LEFT JOIN "rmA_Main"."dbo"."POLICY_X_CVG_TYPE" "POLICY_X_CVG_TYPE" (NOLOCK) ON "POLICY_X_CVG_TYPE"."POLCVG_ROW_ID" = "POLICY_X_CVG_TYPE_Ctrl"."POLCVG_ROW_ID"
				LEFT JOIN
					(
						SELECT
							"POLCVG_ROW_ID", MIN("CVG_LOSS_ROW_ID") "CVG_LOSS_ROW_ID"
						FROM
							"rmA_Main"."dbo"."COVERAGE_X_LOSS" "COVERAGE_X_LOSS" (NOLOCK)
						GROUP BY "POLCVG_ROW_ID"
					) "COVERAGE_X_LOSS_Ctrl" ON "COVERAGE_X_LOSS_Ctrl"."POLCVG_ROW_ID" = "POLICY_X_CVG_TYPE"."POLCVG_ROW_ID"

				LEFT JOIN "rmA_Main"."dbo"."COVERAGE_X_LOSS" "COVERAGE_X_LOSS" (NOLOCK) ON "COVERAGE_X_LOSS"."CVG_LOSS_ROW_ID" = "COVERAGE_X_LOSS_Ctrl"."CVG_LOSS_ROW_ID"
				LEFT JOIN "rmA_Main"."dbo"."CVG_TYPE_SUPP" "CVG_TYPE_SUPP" (NOLOCK) ON "CVG_TYPE_SUPP"."POLCVG_ROW_ID" = "POLICY_X_CVG_TYPE"."POLCVG_ROW_ID"
				LEFT JOIN "rmA_Main"."dbo"."CODES_TEXT" "CT_COV" (NOLOCK) ON "CT_COV"."CODE_ID" = "POLICY_X_CVG_TYPE"."COVERAGE_TYPE_CODE"
				LEFT JOIN "rmA_Main"."dbo"."CODES_TEXT" "CT_PER" (NOLOCK) ON "CT_PER"."CODE_ID" = "COVERAGE_X_LOSS"."LOSS_CODE"
				LEFT JOIN "rmA_Main"."dbo"."POLICY_SUPP" "D" (NOLOCK)
					ON "POLICY"."POLICY_ID" = "D"."POLICY_ID"
			WHERE
					1=1
	) "X"
	--where "X"."POL_NUM" is not null
			--AND "D"."POL_BUSUNIT_TEXT" in ('Property', 'E&S Property') 
			--AND "D"."POL_BSUBDIV_TEXT" in ('E&S Property','Global Property','Onshore Energy - New','Retail Property')
		    --AND "CT_CTD"."SHORT_CODE" = 'PR'
            --AND "CLAIM"."CLAIM_TYPE_CODE" = 58 -- 58 PR Property -- 21144 rw in rmA_Main 20210410102531 on LCL
/*
Filter for the given claim type. This was used to assume the LOB. It could also be based on the policy # on the claim.
this should be filtered on the CLAIM_TYPE_CODE field using the CODE_ID below
Select CODES.CODE_ID, CODES_TEXT.SHORT_CODE,CODES_TEXT.CODE_DESC
From CODES
JOIN CODES_TEXT ON CODES_TEXT.CODE_ID = CODES.CODE_ID
Where TABLE_ID = 1023 AND DELETED_FLAG <> -1
*/
GO


