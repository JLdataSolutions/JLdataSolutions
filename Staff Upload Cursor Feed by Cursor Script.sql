-- Data passed into this Stored Procedure from Cursor Script.
-- The Stored procedure then first checks if Staff Value already exits as a pre entry check. It them passes through a number of tables creating Staff user 
USE [Engine_JLan]
GO
/****** Object:  StoredProcedure [dbo].[pes_Staff_Create_JL_CURSOR]    Script Date: 01/12/2021 15:15:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[pes_Staff_Create_JL_CURSOR]
@LastName nvarchar(20),--= 'Gamboa', --1 
@FirstName nvarchar(60),-- = 'Alyssa', --1 2
@Name nvarchar (255),--= 'Alyssa Gamboa', --1
@Initials nvarchar(10),-- = 'AG', --2
@Title nvarchar(30),--= 'Ms', --2
@Sex nvarchar(10),-- = 'Female', --2
@Reference nvarchar(10),-- = '12345', --3
@Org int,-- = 1, --3
@Office nvarchar(10),--= 'DUBLIN', --3
@Dept nvarchar(10),-- ='INTFIN', --3
@Sub nvarchar(10),-- = 'UNKNOWN', --4
@Grade nvarchar(10),-- = 'ADMIN', --3
@HireDate Date,
@EMail nvarchar(255),--= 'Alyssa.Gamboa@ie.gt.com',--3
@UserId nvarchar(255),-- = 'Alyssa.Gamboa@ie.gt.com', --3
@Type tinyint,-- = 1, --3
@CreatedBy nvarchar(256) --= 'fgs/Anne Mulligan' --1 5

AS

DECLARE @NewStaffIndex int
DECLARE @Cont int --4
SET @NewStaffIndex = 0

--//  Put the whole process into a TRAN:
--if you are creating a record or updating a record or deleting a record from the table, 
--then you are performing a transaction on that table. 
--It is important to control these transactions to ensure the data integrity and to handle database errors 
SET NOCOUNT ON

	--IF (Select Count(*) From tblStaff Where StaffCode = @UserId) > 0  This was the original saftty net based on using @Code  12345
	  IF (Select Count(*) From tblStaff Where Staffreference = @Reference) > 0
		BEGIN
		RAISERROR('You cannot create this staff member, the code is already in use.L41', 14 , 1);--https://docs.microsoft.com/en-us/sql/relational-databases/errors-events/database-engine-error-severities?redirectedfrom=MSDN&view=sql-server-ver15
		GOTO FINISH
		END

	IF (Select Count(*) From tblStaff Where Staffreference = @Reference) > 0
		BEGIN
		RAISERROR('You cannot create this staff member, the user id is already in use.L47', 14 , 1);
		GOTO FINISH
		END

--TABLE 1
--//  Add new record into tblContact, supply constants and retrieve the SCOPE_IDENTITY()
	INSERT INTO tblContacts  (ContType, ContShort, ContSalutation, ContName, ContBusiness,  ContCreated, ContCreatedBy, ContUpdated, ContUpdatedBy)
						VALUES (5,      @LastName, @FirstName,     @Name,    'UNKNOWN',     GETDATE(),    @CreatedBy,    GETDATE(),   @CreatedBy)

--Returns 0 if the previous Transact-SQL statement encountered no errors,Returns an error number if the previous statement encountered an error
	IF @@ERROR <> 0
		BEGIN
		RAISERROR('Error creating staff member, the contact details could not be created. L59', 14 , 1);
		GOTO FINISH
		END
	ELSE
		SET @Cont = Scope_Identity() --returns the id of last inserted record to @cont

--Table 2
	--// Add new record into tblPerson
	INSERT INTO tblPerson ( ContIndex, PersonInitials, PersonForenames, PersonKnownAs, PersonTitle, PersonSuffix, PersonSex, PersonCreated, PersonUpdated, PersonUpdatedBy )
	SELECT                 C.ContIndex, @Initials,     @FirstName,      @FirstName,     @Title,          '',       @Sex,     C.ContCreated, C.ContUpdated, C.ContUpdatedBy
	FROM tblContacts AS C
	WHERE C.ContIndex = @Cont

	IF @@ERROR <> 0
		BEGIN
		RAISERROR('Error creating staff member, the person details could not be created. L74', 14 , 1);
		GOTO FINISH
		END

--Table 3
	--// Add new record into tblStaff // Change StaffCode(@Code) To @Cont ALSo use new Staff Reference instead of C.Contindex
	INSERT INTO tblStaff ( StaffIndex, StaffReference, StaffCode, StaffName, StaffSurname, StaffOrganisation, StaffOffice, StaffDepartment, StaffStarted, StaffType, StaffTimeChg,           StaffTimeNonChg,      StaffTimeService,         StaffTimeServNon,    StaffTimeEntry, StaffUser, StaffCategory, StaffEMail )
	SELECT               C.ContIndex,  @Reference,   C.ContIndex ,    C.ContName, C.ContShort,  @Org,             @Office,      @Dept,           @HireDate,    @Type,    T.TranSetTimeChargeDef, T.TranSetTimeNonchDef, T.TranSetTimeServiceDef, T.TranSetTimeInternDef, 'WEB',       @UserId,   @Grade,        @EMail
	FROM tblContacts AS C, tblTransactionSettings AS T
	WHERE C.ContIndex = @Cont

	IF @@ERROR <> 0
		BEGIN
		RAISERROR('Error creating staff member, the staff details could not be created. L87', 14 , 1);
		GOTO FINISH
		END

	--// Add new record into tblStaffEx
	INSERT INTO tblStaffEx ( StaffIndex, StaffSubDepartment)
	VALUES (@Cont, @Sub)

	IF @@ERROR <> 0
		BEGIN
		RAISERROR('Error creating staff member, the staff extended details could not be created. L97', 14 , 1);
		GOTO FINISH
		END

	insert into tblStaffChanges(StaffIndex,  StaffOrganisation,  StaffOffice,    StaffDepartment,   StaffSubDepartment,   StaffCategory,   ChangeDate,     ChangeType, ChangeDateEnd, ChangeTypeEnd, Comments,    Created,   CreatedBy)
	select                     s.StaffIndex, s.StaffOrganisation, s.StaffOffice, s.StaffDepartment, x.StaffSubDepartment, s.StaffCategory, s.StaffStarted, 'START',     NULL,          NULL,         'New Staff', GetDate(), @CreatedBy
	from tblStaff s
	inner join tblStaffEx x on s.StaffIndex = x.StaffIndex
	where s.StaffIndex = @Cont

	IF @@ERROR <> 0
		BEGIN
		RAISERROR('Error creating staff member, the staff change details could not be created. L109', 14 , 1);
		GOTO FINISH
		END

	INSERT INTO [dbo].[tblStaffSettings]([StaffIndex], [SettingName], [SettingValue])
	SELECT @Cont, N'cssfile', N'PracticeEngine.css' UNION ALL
	SELECT @Cont, N'hagridpagesize', N'50' UNION ALL
	SELECT @Cont, N'spelllang', N'en-GB' UNION ALL
	SELECT @Cont, N'timestyle', LTRIM(STR(TranSetTimeStyle))
	FROM tblTransactionSettings

	IF @@ERROR <> 0
		BEGIN
		RAISERROR('Error creating staff member, the default settings could not be created.L122', 14 , 1);
		GOTO FINISH
		END

	IF @Type < 4
		BEGIN
		INSERT INTO tblStaffOffices(StaffIndex, OfficeCode)
		VALUES (@Cont, @Office)

		INSERT INTO tblStaffOrgs(StaffIndex, PracID)
		VALUES (@Cont, @Org)

		INSERT INTO tblStaffDepts(StaffIndex, DeptIdx)
		VALUES (@Cont, @Dept)
		END

	SET @NewStaffIndex = @Cont

FINISH:
	
	SELECT @NewStaffIndex As Code, 'New Staff Index' As [Desc]

