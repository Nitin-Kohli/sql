USE [CBO2122]
GO
/****** Object:  StoredProcedure [dbo].[CBOCHAT_CBODEVELOPMENT_MAIN_GRID]    Script Date: 10/21/2021 4:37:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CBOCHAT_CBODEVELOPMENT_MAIN_GRID]
(
@LOGIN_PA_ID				AS INT
,@LOGIN_COMPANY_ID			AS INT
,@FDATE						AS DATETIME
,@TDATE						AS DATETIME
,@SRS_STATUS				AS VARCHAR(255)
,@SQL_STATUS				AS VARCHAR(255)
,@API_STATUS				AS VARCHAR(255)
,@TESTING_STATUS			AS VARCHAR(255)
,@BUILD_STATUS				AS VARCHAR(255)
,@CLIENT_STATUS				AS VARCHAR(255)
)
AS
BEGIN



	--PENDING_DAY	PRIORITY_NO	DOC_NO	DOC_DATE	COMPANY_CODE	
	--REMARK	PLAN	PAGE_CODE	SRS_STATUS	SQL_STATUS	
	--API_STATUS	UI_STATUS	TESTING_STATUS	BUILD_STATUS	CLIENT_STATUS
	SET NOCOUNT ON

	SET @SRS_STATUS = dbo.BLANKZERO(@SRS_STATUS);
	SET @SQL_STATUS = dbo.BLANKZERO(@SQL_STATUS);
	SET @API_STATUS = dbo.BLANKZERO(@API_STATUS);
	SET @TESTING_STATUS = dbo.BLANKZERO(@TESTING_STATUS);
	SET @BUILD_STATUS = dbo.BLANKZERO(@BUILD_STATUS);
	SET @CLIENT_STATUS = dbo.BLANKZERO(@CLIENT_STATUS);
	
	SELECT
	PHCOMPLAINT.ID
	,DATEDIFF( D , PHCOMPLAINT.LATEST_PRIORITY_TIME , GETDATE()) AS PENDING_DAY
	,PHCOMPLAINT.PRIORITY		
	,PHCOMPLAINT.DOC_NO			
	,PHCOMPLAINT.DOC_DATE
	,PHPARTY.COMPANY_CODE		
	,PHCOMPLAINT.REMARK
	,PHCOMPLAINT.PAGE_CODE
	,DEV.SRS AS SRS_STATUS
	,DEV.[SQL] AS SQL_STATUS
	,DEV.API AS API_STATUS
	,DEV.UI AS UI_STATUS
	,DEV.TESTING AS TESTING_STATUS
	,DEV.BUILD AS BUILD_STATUS
	,PHCOMPLAINT.[STATUS]	AS CLIENT_STATUS
	,CASE WHEN DEV.SRS IS NOT NULL THEN 'SRS' ELSE '' END
	+ CASE WHEN DEV.SQL IS NOT NULL THEN ' SQL' ELSE '' END
	+ CASE WHEN DEV.API IS NOT NULL THEN ' API' ELSE '' END
	+ CASE WHEN DEV.UI IS NOT NULL THEN ' UI' ELSE '' END
	+ CASE WHEN DEV.TESTING IS NOT NULL THEN ' TESTING' ELSE '' END
	+ CASE WHEN DEV.BUILD IS NOT NULL THEN ' BUILD' ELSE '' END
	AS [PLAN]
	,30	 AS PLAN_ICON

	FROM PHCOMPLAINT WITH(NOLOCK)
	INNER JOIN  PHPARTY  WITH(NOLOCK) ON	PHPARTY.PA_ID = PHCOMPLAINT.PA_ID
	AND PHCOMPLAINT.DOC_DATE >=@FDATE AND PHCOMPLAINT.DOC_DATE<@TDATE
	LEFT OUTER JOIN 
		(
		SELECT D.COMPLAINT_ID
				,MAX(CASE WHEN A.FIELD_VALUE='API' THEN D.STATUS ELSE '' END) AS API
				,MAX(CASE WHEN A.FIELD_VALUE='BUILD' THEN D.STATUS ELSE '' END) AS BUILD
				,MAX(CASE WHEN A.FIELD_VALUE='SQL' THEN D.STATUS ELSE '' END) AS SQL
				,MAX(CASE WHEN A.FIELD_VALUE='SRS' THEN D.STATUS ELSE '' END) AS SRS
				,MAX(CASE WHEN A.FIELD_VALUE='TESTING' THEN D.STATUS ELSE '' END) AS TESTING
				,MAX(CASE WHEN A.FIELD_VALUE='UI' THEN D.STATUS ELSE '' END) AS UI
				FROM PHCOMPLAINTDEV D WITH(NOLOCK)
				INNER JOIN PHALLMST A WITH(NOLOCK) ON D.DEPTDEV_ID = A.ID
				GROUP BY D.COMPLAINT_ID
		)DEV ON PHCOMPLAINT.ID = DEV.COMPLAINT_ID
	WHERE 
		(PHCOMPLAINT.[STATUS] ='0' OR PHCOMPLAINT.[STATUS] = @CLIENT_STATUS)
		AND (@SRS_STATUS ='0' OR DEV.SRS = @SRS_STATUS)
		AND (@SQL_STATUS ='0' OR DEV.[SQL] = @SQL_STATUS)
		AND (@API_STATUS ='0' OR DEV.API = @API_STATUS)
		AND (@TESTING_STATUS ='0' OR DEV.TESTING = @TESTING_STATUS)
		AND (@BUILD_STATUS ='0' OR DEV.BUILD = @BUILD_STATUS)

	--SETTING	
	SELECT '' AS BLANK 
	
	SET NOCOUNT OFF

END
