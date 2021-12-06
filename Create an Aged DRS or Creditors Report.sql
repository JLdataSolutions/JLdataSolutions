-- Create an Aged debtors or Creditors report
-- Simple clean Solution, Step 1 First create an Aged Table and Insert into this using any aged crteria required DateDiff and GetDate Functions are handy here. Step 2 once you have this you can then join to further tables needed to populate with requested data 
USE [Test_GTI]
GO
/****** Object:  StoredProcedure [dbo].[pe6_rpt_AgedDRS_DeptCManager_Details_JL]    Script Date: 01/12/2021 15:37:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[pe6_rpt_AgedDRS_DeptCManager_Details_JL]

@Staff int

AS

DECLARE @PracName VarChar(255)

SET @PracName = dbo.udf_PracName()

CREATE TABLE #AgedDRS (
	ContIndex int NOT NULL ,
	OrgID tinyint NOT NULL ,
	DRSTotal money NOT NULL ,
	DRSFuture money NOT NULL,
	DRS1 money NOT NULL ,
	DRS2 money NOT NULL ,
	DRS3 money NOT NULL ,
	DRS4 money NOT NULL ,
	DRS5 money NOT NULL)

--// Insert initial details
INSERT INTO #AgedDRS ( ContIndex, OrgID, DRSTotal, DRSFuture, DRS1, DRS2, DRS3, DRS4, DRS5)
SELECT D.ContIndex, E.ClientOrganisation,
		Coalesce(Sum(D.DebtTranUnpaid),0),
		Coalesce(Sum(CASE WHEN D.DebtTranDate > Getdate() THEN D.DebtTranUnpaid ELSE 0 END),0),
		Coalesce(Sum(CASE WHEN DateDiff(dd,D.DebtTranDate,Getdate())+1 Between 0 And 60 THEN D.DebtTranUnpaid ELSE 0 END),0),
		Coalesce(Sum(CASE WHEN DateDiff(dd,D.DebtTranDate,Getdate())+1 Between 61 And 120 THEN D.DebtTranUnpaid ELSE 0 END),0),
		Coalesce(Sum(CASE WHEN DateDiff(dd,D.DebtTranDate,Getdate())+1 Between 121 And 180 THEN D.DebtTranUnpaid ELSE 0 END),0),
		Coalesce(Sum(CASE WHEN DateDiff(dd,D.DebtTranDate,Getdate())+1 Between 181 And 270 THEN D.DebtTranUnpaid ELSE 0 END),0),
		Coalesce(Sum(CASE WHEN DateDiff(dd,D.DebtTranDate,Getdate())+1 > 270 THEN D.DebtTranUnpaid ELSE 0 END),0)
FROM tblJLTranDebtor D
INNER JOIN tblJLEngagement E ON D.ContIndex = E.ContIndex 
WHERE D.ContIndex < 900000 AND D.DebtTranUnpaid <> 0
GROUP BY D.ContIndex, E.ClientOrganisation


Select 		C.PracID, C.PracName, O.OfficeCode, O.OfficeTitle, D.DeptIdx, D.DeptName, S.StaffIndex, S.StaffSurname, S.StaffName,
		E.ContIndex, E.ClientCode, E.ClientName, S1.Staffname As Partner, 
		Sum(A.DRSTotal) AS Total, 
		Sum(A.DRS1 + A.DRSFuture) AS Curr, 
		Sum(DRS2) AS Days60, 
		Sum(DRS3) AS Days120, 
		Sum(DRS4) AS Days180, 
		Sum(DRS5) AS Days270, 
		@PracName As PEName, GetDate() As DateTo
From 		tblEngagement E 
INNER JOIN 	tblStaff S ON E.ClientManager = S.StaffIndex 
INNER JOIN	tblDepartment D ON S.StaffDepartment = D.DeptIdx
INNER JOIN	tblOffices O ON E.ClientOffice = O.OfficeCode
INNER JOIN	tblControl C ON E.ClientOrganisation = C.PracID
INNER JOIN tblstaff S1 ON E.ClientPartner = S1.StaffIndex 
INNER JOIN	#AgedDRS A ON E.ContIndex = A.ContIndex
GROUP BY 	C.PracID, C.PracName, O.OfficeCode, O.OfficeTitle, D.DeptIdx, D.DeptName, S.StaffIndex, S.StaffSurname, S.StaffName, E.ContIndex, E.ClientCode, E.ClientName,S1.Staffname
HAVING		Sum(A.DRSTotal) <> 0 OR
		Sum(A.DRS1 + A.DRSFuture) <> 0 OR
		Sum(DRS2)  <> 0  OR 
		Sum(DRS3)  <> 0  OR 
		Sum(DRS4)  <> 0  OR 
		Sum(DRS5)  <> 0 
ORDER BY 	D.DeptName, S.StaffSurname, S.StaffName, E.ClientName



