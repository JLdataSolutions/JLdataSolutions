--Create A staff List with Annual leave blances against targets set at three point in a calender year, This list must then be compared to Staff planning system to establish if targets are to be adjsuted per staff row.
USE [TEST_GTI]
GO
/****** Object:  StoredProcedure [dbo].[PE6_rpt_GT_TOIL_&_LEAVEMovement_ROI&NI_FLOAT]    Script Date: 01/12/2021 15:08:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[PE6_rpt_GT_TOIL_&_LEAVEMovement_ROI&NI_FLOAT]
	@Staff Int = 38864
AS

DECLARE @LastYStart DateTime,
		        @LastYEnd DateTime,
		        @ThisYStart DateTime,
	            @ThisYEnd DateTime
	
	SELECT		@LastYStart = '1 Jan 2020', @LastYEnd = '31 Dec 2020', @ThisYStart = '1 Jan 2021', @ThisYEnd = '31 Dec 2021'

--OLD ---------------------------------------------------------------------------------------------------------------------------------------
SELECT		StaffIndex,StaffName, Type, Analysis, Sum(Hours) AS Hours
	INTO		#Old
	FROM	(
			--TOIL Movement
			SELECT		
			TT.StaffIndex, 
			S.StaffName,
			Case When TOILCat = 'TOIL' Then 'TOIL' 
				 Else 'LEAVE' 
				 End AS Type,
									 
			Case When TOILHours < 0 And TOILAnalysis = 'OT' Then 'OTA' 
				 When TOILHours > 0 AND TOILAnalysis = 'OT' THEN 'OTT' Else TOILAnalysis 
				 End AS Analysis,
			Sum(TOILHours) AS Hours
			FROM		tblTOIL_Transactions TT INNER Join
						tblStaff S on TT.StaffIndex = S.StaffIndex
			WHERE		S.StaffDepartment = 'FAS' and S.StaffEnded IS NULL AND  TT.WIPIndex = 0 AND TT.TimeSheetDate < @LastYStart
			GROUP BY	TT.StaffIndex,S.StaffNAme, Case When TOILCat = 'TOIL' Then 'TOIL' Else 'LEAVE' End, Case When TOILHours < 0 And TOILAnalysis = 'OT' Then 'OTA' When TOILHours > 0 AND TOILAnalysis = 'OT' THEN 'OTT' Else TOILAnalysis End
	
			UNION ALL
			
			SELECT		
			tblTranWIP.StaffIndex,S1.StaffName, 
			Case When ChargeType = 'TOIL' Then 'TOIL' 
			     Else 'LEAVE' 
				 End AS Type, 
				 
			Case When WIPHours < 0 And WIPAnalysis = 'OT' Then 'OTA' 
			     When WIPHours > 0 AND WIPAnalysis = 'OT' THEN 'OTT' Else WIPAnalysis 
				 End AS Analysis, 
			Sum(WIPHours) AS Hours
			FROM		tblTranWIP INNER JOIN
					tblTimeChargeCode ON WIPAnalysis = ChargeCode INNER JOIN
					tblStaff S1 on tblTranWIP.StaffIndex = S1.StaffIndex
			WHERE		WIPDate < @LastYStart
					AND TransTypeIndex = 1
					AND ChargeType IN ('TOIL', 'LEAV', 'LEAVE')
					AND S1.StaffDepartment = 'FAS' AND S1.StaffEnded IS NULL
			GROUP BY	tblTranWIP.StaffIndex, S1.StaffNAme, Case When ChargeType = 'TOIL' Then 'TOIL' Else 'LEAVE' End, Case When WIPHours < 0 And WIPAnalysis = 'OT' Then 'OTA' When WIPHours > 0 AND WIPAnalysis = 'OT' THEN 'OTT' Else WIPAnalysis End
		) AS PriorTransactions
	GROUP BY	StaffIndex,StaffName, Type, Analysis


--Last Year----------------------------------------------------------------------
SELECT		StaffIndex, Type, Analysis, Sum(Hours) AS Hours
	INTO		#LastYear
	FROM	(
			SELECT		tblTOIL_Transactions.StaffIndex, Case When TOILCat = 'TOIL' Then 'TOIL' Else 'LEAVE' End AS Type, Case When TOILHours < 0 And TOILAnalysis = 'OT' Then 'OTA' When TOILHours > 0 AND TOILAnalysis = 'OT' THEN 'OTT' Else TOILAnalysis End AS Analysis, Sum(TOILHours) AS Hours
			FROM		tblTOIL_Transactions INNER JOIN
					tblStaff S1 on tblTOIL_Transactions.StaffIndex = S1.StaffIndex
			WHERE		WIPIndex = 0 AND TimeSheetDate BETWEEN @LastYStart AND @LastYEnd AND S1.StaffDepartment = 'FAS' AND S1.StaffEnded IS NULL
			GROUP BY	tblTOIL_Transactions.StaffIndex, Case When TOILCat = 'TOIL' Then 'TOIL' Else 'LEAVE' End, Case When TOILHours < 0 And TOILAnalysis = 'OT' Then 'OTA' When TOILHours > 0 AND TOILAnalysis = 'OT' THEN 'OTT' Else TOILAnalysis End
			UNION ALL
			SELECT		tblTranWIP.StaffIndex, Case When ChargeType = 'TOIL' Then 'TOIL' Else 'LEAVE' End AS Type, Case When WIPHours < 0 And WIPAnalysis = 'OT' Then 'OTA' When WIPHours > 0 AND WIPAnalysis = 'OT' THEN 'OTT' Else WIPAnalysis End AS Analysis, Sum(WIPHours) AS Hours
			FROM		tblTranWIP INNER JOIN
					tblTimeChargeCode ON WIPAnalysis = ChargeCode INNER JOIN
					tblStaff S2 on tblTranWIP.staffindex = s2.staffIndex
			WHERE		WIPDate BETWEEN @LastYStart AND @LastYEnd and S2.StaffDepartment = 'FAS' AND S2.StaffEnded IS NULL
					AND TransTypeIndex = 1
					AND ChargeType IN ('TOIL', 'LEAV', 'LEAVE')
			GROUP BY	tblTranWIP.StaffIndex, Case When ChargeType = 'TOIL' Then 'TOIL' Else 'LEAVE' End, Case When WIPHours < 0 And WIPAnalysis = 'OT' Then 'OTA' When WIPHours > 0 AND WIPAnalysis = 'OT' THEN 'OTT' Else WIPAnalysis End
		) AS LastYearTransactions
	GROUP BY	StaffIndex, Type, Analysis
--This Year-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT		StaffIndex, Type, Analysis, Sum(Hours) AS Hours
	INTO		#ThisYear
	FROM	(
			SELECT		StaffIndex, Case When TOILCat = 'TOIL' Then 'TOIL' Else 'LEAVE' End AS Type, Case When TOILHours < 0 And TOILAnalysis = 'OT' Then 'OTA' When TOILHours > 0 AND TOILAnalysis = 'OT' THEN 'OTT' Else TOILAnalysis End AS Analysis, Sum(TOILHours) AS Hours
			FROM		tblTOIL_Transactions
			WHERE		WIPIndex = 0 AND TimeSheetDate BETWEEN @ThisYStart AND @ThisYEnd
			GROUP BY	StaffIndex, Case When TOILCat = 'TOIL' Then 'TOIL' Else 'LEAVE' End, Case When TOILHours < 0 And TOILAnalysis = 'OT' Then 'OTA' When TOILHours > 0 AND TOILAnalysis = 'OT' THEN 'OTT' Else TOILAnalysis End
			UNION ALL
			SELECT		StaffIndex, Case When ChargeType = 'TOIL' Then 'TOIL' Else 'LEAVE' End AS Type, Case When WIPHours < 0 And WIPAnalysis = 'OT' Then 'OTA' When WIPHours > 0 AND WIPAnalysis = 'OT' THEN 'OTT' Else WIPAnalysis End AS Analysis, Sum(WIPHours) AS Hours
			FROM		tblTranWIP INNER JOIN
					tblTimeChargeCode ON WIPAnalysis = ChargeCode
			WHERE		WIPDate BETWEEN @ThisYStart AND @ThisYEnd
					AND TransTypeIndex = 1
					AND ChargeType IN ('TOIL', 'LEAV', 'LEAVE')
			GROUP BY	StaffIndex, Case When ChargeType = 'TOIL' Then 'TOIL' Else 'LEAVE' End, Case When WIPHours < 0 And WIPAnalysis = 'OT' Then 'OTA' When WIPHours > 0 AND WIPAnalysis = 'OT' THEN 'OTT' Else WIPAnalysis End
		) AS ThisYearTransactions
	GROUP BY	StaffIndex, Type, Analysis

	--SELECT * FROM #ThisYear where staffindex = 30729

--Leave_CF table-------------------------------------------------------------------------------------------------------------------------------------
SELECT S.StaffName,S.StaffIndex,
	Coalesce((SELECT Sum(Hours) * -1 FROM #ThisYear T WHERE T.StaffIndex = S.StaffIndex AND T.Type = 'LEAVE' AND T.Analysis = 'BALANCE'), 0)
				/ Case When Coalesce(ST.StaffDailyHours, 0) = 0 Then 7.25 Else ST.StaffDailyHours End AS LEAVE_Ent_2021,

	(Coalesce((SELECT Sum(Hours) * -1 FROM #LastYear L WHERE L.StaffIndex = S.StaffIndex AND L.Type = 'LEAVE'), 0) +
				Coalesce((SELECT Sum(Hours) * -1 FROM #Old O WHERE O.StaffIndex = S.StaffIndex AND O.Type = 'LEAVE'), 0))
				/ Case When Coalesce(ST.StaffDailyHours, 0) = 0 Then 7.25 Else ST.StaffDailyHours End AS LEAVE_CFwd_2021
INTO #Leave_CF
FROM		tblStaff S
			INNER JOIN tblOffices O on S.StaffOffice = O.OfficeCode
			INNER JOIN tblDepartment D ON S.StaffDepartment = D.DeptIdx
			INNER JOIN tblCategory C ON S.StaffCategory = C.Category
			INNER JOIN tblStaff_TOIL ST ON S.StaffIndex = ST.StaffIndex
			Left JOIN TblStaffEX X on S.StaffIndex = X.staffIndex
			INNER JOIN tblControl P ON S.StaffOrganisation = P.PracID
	WHERE		S.StaffEnded IS NULL and s.StaffDepartment = 'FAS'
			AND C.CatType = 'GRADE'

--SELECT * FROM #Leave_CF where staffindex = 30729

--Float Tables -----------------------------------------------------------------------------------------------------------------------
SELECT        *
INTO #Float_ALL
FROM  Engine_GTI_TEST.dbo.tblFloat_DB
WHERE [Time Off] = 'Annual Leave'--Hours > 0 

SELECT        *
INTO #Float_ALL_Ranking
FROM  Engine_GTI_TEST.dbo.tblFloat_DB
WHERE [Time Off] = 'Annual Leave' and Hours > 0 

SELECT StaffIndex,Name,[Job Title],Sum(Hours)/7.5 AS AL_Booked
INTO #Float_SUM
FROM  Engine_GTI_TEST.dbo.tblFloat_DB
WHERE [Time Off] = 'Annual Leave' 
GROUP BY StaffIndex,Name,[Job Title]

--Join & Comparison Tables-------------------------------------------------------------------------------------------------------
SELECT #Leave_CF.staffindex, #Leave_CF.StaffName,#Float_SUM.[Job Title], ROUND(#Leave_CF.LEAVE_Ent_2021,2) As Leave_Ent, ROUND(#Leave_CF.LEAVE_CFwd_2021,2) As Leave_CF, 
Coalesce(#Float_SUM.AL_Booked,0) AS AL_Booked
INTO #COMP1
FROM #Leave_CF Left Join
#Float_Sum on #Leave_CF.staffindex = #Float_SUM.staffindex

--STEP 1-2 Table <= 0 , All staff that calculation on
SELECT StaffIndex, StaffName,[Job Title],Leave_Ent,AL_Booked,Leave_CF
INTO #STEP1
FROM #COMP1
WHERE (Leave_CF <= 0.99)

--STEP 3 Table Leave_CF > AL_Booked Feed Table, All staff just with 5,7, 8
SELECT StaffIndex, StaffName,[Job Title],Leave_Ent,AL_Booked,Leave_CF
INTO #STEP2
FROM #COMP1
WHERE  (Leave_CF >= AL_Booked)

--STEP 4 Leave Cf > 0 and < AL_Booked-------------------------------------------------------------------------------------
SELECT StaffIndex, StaffName,[Job Title],Leave_Ent,AL_Booked,Leave_CF
INTO #STEP3
FROM #COMP1
WHERE  (Leave_CF >0.99) and (Leave_CF < AL_Booked) 
--Next Step 1st table in 1st Final Union---------------------------------------------------------------------------------------------------
--THese are staff who have no Leave CF Condition
SELECT 
#STEP1.staffindex, 
#STEP1.StaffName, 
#STEP1.[Job Title],
#STEP1.Leave_Ent,
#STEP1.AL_Booked,
#STEp1.Leave_CF,
ROUND(SUM(Hours)/7.50,2)  AS ALBooked,    
ROUND(SUM(CASE WHEN Month(date) In (1,2,3,4,5,6) Then Hours ELSE 0 END)/7.50,2)  AS ToJune,
ROUND(SUM(CASE WHEN Month(date) In (7,8) Then Hours ELSE 0 END)/7.50,2)  AS ToAugust,
ROUND(SUM(CASE WHEN Month(date) In (9,10,11,12) Then Hours ELSE 0 END)/7.50,2)  AS ToDec,
ROUND(SUM(CASE WHEN Month(date) In (1,2,3,4,5,6) Then Hours ELSE 0 END)/7.50,2)  AS ToJune_Cum,
ROUND(SUM(CASE WHEN Month(date) In (1,2,3,4,5,6,7,8) Then Hours ELSE 0 END)/7.50,2)  AS ToAugust_Cum,
ROUND(SUM(CASE WHEN Month(date) In (1,2,3,4,5,6,7,8,9,10,11,12) Then Hours ELSE 0 END)/7.50,2)  AS ToDec_Cum
INTO #STEP1a
FROM #STEP1 LEFt JOIN
#Float_ALL on #STEP1.StaffIndex = #Float_ALL.StaffIndex
GROUP by #STEP1.staffindex, #STEP1.StaffName, #STEP1.[Job Title],#STEP1.Leave_Ent,#STEP1.AL_Booked,#STEp1.Leave_CF

--These are staff with Leave_CF > AL BOOKED so just get 5, 7, 8----------------------------------------------------------------------------
SELECT 
#STEP2.staffindex, 
#STEP2.StaffName, 
#STEP2.[Job Title],
#STEP2.Leave_Ent,
#STEP2.AL_Booked,
#STEP2.Leave_CF,
ROUND(SUM(Hours)/7.50,2)  AS ALBooked,    
ROUND(SUM(CASE WHEN Month(date) In (1,2,3,4,5,6) Then Hours ELSE 0 END)/7.50,2)  AS ToJune,
ROUND(SUM(CASE WHEN Month(date) In (7,8) Then Hours ELSE 0 END)/7.50,2)  AS ToAugust,
ROUND(SUM(CASE WHEN Month(date) In (9,10,11,12) Then Hours ELSE 0 END)/7.50,2)  AS ToDec,
ROUND(SUM(CASE WHEN Month(date) In (1,2,3,4,5,6) Then Hours ELSE 0 END)/7.50,2)  AS ToJune_Cum,
ROUND(SUM(CASE WHEN Month(date) In (1,2,3,4,5,6,7,8) Then Hours ELSE 0 END)/7.50,2)  AS ToAugust_Cum,
ROUND(SUM(CASE WHEN Month(date) In (1,2,3,4,5,6,7,8,9,10,11,12) Then Hours ELSE 0 END)/7.50,2)  AS ToDec_Cum
INTO #STEP2a
FROM #STEP2 LEFt JOIN
#Float_ALL on #STEP2.StaffIndex = #Float_ALL.StaffIndex
GROUP by #STEP2.staffindex, #STEP2.StaffName, #STEP2.[Job Title],#STEP2.Leave_Ent,#STEP2.Leave_Ent,#STEP2.AL_Booked,#STEP2.Leave_CF

--THESE Staff have CF but less than AL Booked---------------------------
SELECT 
#STEP3.StaffIndex, 
#STEP3.StaffName, 
#STEP3.Leave_Ent, 
#COMP1.Al_Booked AS ALBooked, 
#COMP1.Leave_CF,
#STEP3.AL_Booked, 
--CEILING(#COMP1.Al_Booked - #COMP1.Leave_CF) AS Adj_AL_Booked 
(#COMP1.Al_Booked - #COMP1.Leave_CF) AS Adj_AL_Booked 
INTO #STEP3a
FROM #STEP3 left join
#COMP1 on #STEP3.staffindex = #COMP1.staffIndex

--SELECT Staff From #Float_ALL Join with #Step3a and Rank by date early to later--------------------------------------------------------------------
SELECT 
#Float_ALL_Ranking.staffindex, 
#Float_ALL_Ranking.Name, 
#Float_ALL_Ranking.[Job Title],
DAte,
#STEP3a.AL_Booked,
#STEP3a.ALBooked, 
#STEP3a.Leave_Ent, 
--Floor(#STEP3a.Leave_CF) As Leave_CF,
#STEP3a.Leave_CF As Leave_CF,
#STEP3a.Adj_AL_Booked,
RANK() OVER(Partition by #Float_ALL_Ranking.staffindex ORDER BY [Date] ASC) as 'Ranking' 
INTO #Ranking
FROM #Float_ALL_Ranking Inner join
#STEP3a on #Float_ALL_Ranking.staffindex = #STEP3a.staffindex
Order By #Float_ALL_Ranking.staffindex, 'Ranking'

--Iteration 1 Table where C fWd Ranking mattered--------------------------
SELECT * 
INTO #Rankinga
FROM #Ranking 
WHERE Ranking > Leave_CF 

--Iteration 2 Table where C fWd Ranking doesn't matter--------------------------
--SELECT * 
--INTO #Rankinga
--FROM #Ranking 


--Now use Ranking table to get 2nd part of Final Union------------------------------------------------------------------------------------------------
SELECT 
staffindex, 
Name, 
[Job Title],
Leave_Ent,
Count(DAte)  AS ALBooked,  
Count(DAte)  AS AL_Booked,  
CASE WHEN Month(date) In (1,2,3,4,5,6) Then Count(Date) ELSE 0 END  AS ToJune,
CASE WHEN Month(date) In (7,8) Then Count(Date) ELSE 0 END  AS ToAugust,
CASE WHEN Month(date) In (9,10,11,12) Then Count(Date) ELSE 0 END  AS ToDec,
CASE WHEN Month(date) In (1,2,3,4,5,6) Then Count(Date) ELSE 0 END  AS ToJune_C,
CASE WHEN Month(date) In (1,2,3,4,5,6,7,8) Then Count(Date) ELSE 0 END  AS ToAugust_C,
CASE WHEN Month(date) In (1,2,3,4,5,6,7,8,9,10,11,12) Then Count(Date) ELSE 0 END  AS ToDec_C
INTO #Rankingb
FROM #Rankinga 
GROUP by StaffIndex, Name, [Job Title],DAte,Leave_Ent
--UNION Two Data sets for 1St Final Dataset------------------------------------------------------------------------------------------------
SELECT * INTO #Final FROM(
SELECT 
Staffindex,
StaffName,
[Job Title],
ALBooked,
AL_Booked,
Leave_Ent,
Leave_CF,
ToJune_Cum,
5-ToJune_Cum AS JuneCumTotal,
--ToJune,
--5-Tojune As JuneTT,
ToAugust_Cum,
12-ToAugust_Cum As AugCumTotal,
--ToAugust,
--7-ToAugust As AugustTT,
ToDec_Cum,
20-ToDec_Cum As DecCumTotal
--ToDec, 
--8-ToDec as DecTT
--5 As ToTakeJune,
--12 As ToTakeAug,
--20 As ToTakeDec

from #STEP1a

UNION

SELECT 
Staffindex,
StaffName,
[Job Title],
ALBooked,
AL_Booked,
Leave_Ent,
Leave_CF,
0 AS ToJune_Cum,
5 AS JuneCumTotal,
--ToJune,
--0 as ToJune,
--5  As JuneTT,
0 AS ToAugust_Cum,
12 As AugCumTotal,
--ToAugust,
--0 as ToAugust,
--7  As AugustTT,
0 AS ToDec_Cum,
20 As DecCumTotal
--ToDec,
--0 as ToDec,
--8 as DecTT
--5 As ToTakeJune,
--12 As ToTakeAug,
--20 As ToTakeDec

from #STEP2a

UNION

SELECT 
R.Staffindex,
R.Name,
R.[Job Title],
SUM(R.ALBooked) As AlBooked,
S3.AL_Booked As AL_Booked,
R.Leave_Ent,
S3.Leave_CF,
SUM(R.ToJune_C)As ToJune_Cum,
5-SUM(R.ToJune_C) As JuneCumTotal,
--5- SUM(ToJune) AS JuneTT,
SUM(R.ToAugust_C)As ToAugust_Cum,
12- SUM(R.ToAugust_C) As AugCumTotal,
--7- SUM(ToAugust) AS AugustTT,
SUM(R.ToDec_C)As ToDec_Cum,
20 - SUM(R.ToDec_C) As DecCumTotal
--8- SUM(ToDec) As DecTT
FROM #Rankingb R Inner Join 
#STEP3a S3 on R.StaffIndex = S3.StaffIndex
Group By R.StaffIndex , R.Name,R.[Job Title],R.Leave_Ent,S3.AL_Booked,S3.Leave_CF
) #Final

SELECT *,
CASE WHEN Leave_CF < AL_BOOKED THEN 0
	 WHEN LEAVE_CF > AL_BOOKED THEN LEAVE_CF - AL_Booked
	 ELSE LEAVE_CF - AL_Booked
	 END AS Balance_AL_2020_Remaining
FROM #Final





--SELECT * FROM #Leave_CF
--SELECT * FROM #Float_ALL
--SELECT * FROM #Float_ALL_Ranking
--SELECT * FROM #Float_SUM
--SELECT * FROM #COMP1
--SELECT * FROM #STEP1
--SELECT * FROM #STEP2
--SELECT * FROM #STEP3
--SELECT * FROM #STEP1a
--SELECT * FROM #STEP3a
---SELECT * FROM #Ranking
--SELECT * FROM #Rankinga
--SELECT * FROM #Rankingb
--SELECT * FROM #1stHalf

DROP Table #OLD
DROP Table #LastYear
DROP Table #Thisyear
DROp Table #Leave_CF
DROP Table #Float_ALL
DROP Table #Float_ALL_Ranking
DROP Table #Float_SUM
DROp Table #COMP1
DROP Table #STEP1
DROP Table #STEP2
DROP Table #STEP3
DROP Table #STEp1a
DROP Table #Step2a
DROP Table #STEp3a
DROP Table #Ranking
DROP Table #Rankinga
DROP Table #Rankingb
DROP Table #Final