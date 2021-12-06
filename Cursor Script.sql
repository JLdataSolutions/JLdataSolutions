--Problem: Staff need to be Extracted from a Source System, Transformed and loaded into a new System.
--Solution Use a Cursor to load data one record at a time. Step 1 Extract data required from Source System, STEP 2 Transform the data using UDF Function. STEP 3 pass data into Stored procedure that loads data into Host System
USE [JLancaster-Test]
GO
/****** Object:  StoredProcedure [dbo].[pes_Staff_Create_JL_TEST_CURSOR_UPLOAD]    Script Date: 01/12/2021 15:12:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[pes_Staff_Create_JL_TEST_CURSOR_UPLOAD]

AS

DECLARE 
@LastName nvarchar(20), 
@FirstName nvarchar(60),
@Name nvarchar (255),
@Initials nvarchar(10),
@Title nvarchar(30),
@Sex nvarchar(10),
@Reference nvarchar(10),
@Org int,
@Office nvarchar(10),
@Dept nvarchar(10),
@Sub nvarchar(10),
@Grade nvarchar(10),
@HireDate Date,
@EMail nvarchar(255),
@UserId nvarchar(256), 
@Type tinyint = 1,
@CreatedBy nvarchar(256)

DECLARE StaffUpload CURSOR
	FOR
--Step 1 & Step 2
SELECT
Lastname,
FirstName,
Name,
Initials,
Title,
Sex,
Reference,
dbo.Org(Org) as Org,--STEP 2 data passed into UDF Function
dbo.Location_Name(Office) As Office,
dbo.SERVICE_LINE(Dept)as Dept,
SubDept,
dbo.Grade(Grade) as Grade,
StartDate,
Email,
User_Id,
Type,
Created_By
 FROM JL_View_FeedStaff where employee_id IN (
'15395',
'15425',
'15397',
'15170',
'15166'
)

--Step 3
OPEN StaffUpload
	--Do Something useful here
	FETCH NEXT FROM StaffUpload -- THIS will Get you one record
		INTO @LastName, @FirstName, @Name, @Initials, @Title, @Sex, @Reference, @Org, @Office, @Dept,@Sub,@Grade, @HireDate,@EMail,@UserId, @Type, @CreatedBy

	WHILE @@FETCH_STATUS = 0
		BEGIN

		EXECUTE [SQLFIN01].[Test_GTI].[dbo].[pes_Staff_Create_JL_CURSOR] @LastName, @FirstName, @Name, @Initials, @Title, @Sex, @Reference, @Org, @Office, @Dept,@Sub,@Grade, @HireDate, @EMail,@UserId, @Type, @CreatedBy
		 FETCH NEXT FROM StaffUpload
		  INTO @LastName, @FirstName, @Name, @Initials, @Title, @Sex, @Reference, @Org, @Office, @Dept,@Sub,@Grade, @HireDate,@EMail,@UserId, @Type, @CreatedBy

	    END
Close StaffUpload
DEALLOCATE StaffUpload