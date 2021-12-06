-- Problem: Data is extracted from one system and uploaded to a seperate system. The Data needs to mapped to correctly loaded and Displayed in new host system using a CURSOR.
--Solution: Once the data is mapped using this function then any data extracted from the source system is passed through this fuction it will correctly map according to the IF statements below and load into new System 


USE [JLancaster-Test]
GO
/****** Object:  UserDefinedFunction [dbo].[ORG]    Script Date: 01/12/2021 15:14:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[ORG](
	@JT VarChar(50)
)
RETURNS VARCHAR(50) AS
BEGIN
	DECLARE @return_value VarChar(50);
	SET @return_value = 1;
		IF  (@JT  = '989 Change & Transformation')  SET  @return_value = 1;
IF  (@JT  = '944 Financial Services Advisory Cork')  SET  @return_value = 2;
IF  (@JT  = '985 FS Audit - Cork')  SET  @return_value = 1;
IF  (@JT  = '550 IT')  SET  @return_value = 1;
IF  (@JT  = '941 National Audit & Assurance - Dublin')  SET  @return_value = 1;
IF  (@JT  = '980 National Audit & Assurance - Limerick')  SET  @return_value = 1;
IF  (@JT  = '80 Financial Services Advisory Galway')  SET  @return_value = 2;
IF  (@JT  = '948 Audit and Assurance BMW - Longford')  SET  @return_value = 1;
IF  (@JT  = 'TAX')  SET  @return_value = 12;
IF  (@JT  = '190 Forensics/IT Security')  SET  @return_value = 2;
IF  (@JT  = '5 GTFC Signature')  SET  @return_value = 12;
IF  (@JT  = '930 FAAS')  SET  @return_value = 1;
IF  (@JT  = '980 Audit & Assurance - Limerick')  SET  @return_value = 1;
IF  (@JT  = '987 FS Audit - Galway')  SET  @return_value = 1;
IF  (@JT  = '20 Business Risk Services')  SET  @return_value = 2;
IF  (@JT  = '3 Grant Thornton Financial Counselling Limerick')  SET  @return_value = 12;
IF  (@JT  = '180 Corporate Finance BMW Longford')  SET  @return_value = 2;
IF  (@JT  = '170 Digital Transformation')  SET  @return_value = 2;
IF  (@JT  = '947 Audit & Assurance - Cork')  SET  @return_value = 1;
IF  (@JT  = '680 Training & Standards')  SET  @return_value = 1;
IF  (@JT  = '9 Client Services Longford')  SET  @return_value = 5;
IF  (@JT  = '131 Operational Advisory')  SET  @return_value = 2;
IF  (@JT  = '675 Human Resources')  SET  @return_value = 1;
IF  (@JT  = '140 Madison')  SET  @return_value = 2;
IF  (@JT  = '11 Tax Limerick')  SET  @return_value = 5;
IF  (@JT  = '941 Audit & Assurance - Dublin')  SET  @return_value = 1;
IF  (@JT  = '954 Business support Newbridge GTD')  SET  @return_value = 1;
IF  (@JT  = 'Advisory')  SET  @return_value = 2;
IF  (@JT  = 'Belfast-CC (HR) Belfast')  SET  @return_value = 1;
IF  (@JT  = '1 Tax Dublin')  SET  @return_value = 5;
IF  (@JT  = '010 Tax BMW Longford')  SET  @return_value = 5;
IF  (@JT  = '90 Debt Solutions')  SET  @return_value = 2;
IF  (@JT  = '30 Business Consulting')  SET  @return_value = 2;
IF  (@JT  = '40 Financial Services Advisory Dublin')  SET  @return_value = 2;
IF  (@JT  = '195 Corporate Finance Cork')  SET  @return_value = 2;
IF  (@JT  = '151 CENTRAL GTFTD')  SET  @return_value = 12;
IF  (@JT  = '991 CENTRAL GTD')  SET  @return_value = 12;
IF  (@JT  = '953 Audit & Assurance BMW - Galway')  SET  @return_value = 1;
IF  (@JT  = '12 Tax Cork')  SET  @return_value = 5;
IF  (@JT  = '700 Marketing')  SET  @return_value = 1;
IF  (@JT  = '8 Corporate compliance')  SET  @return_value = 5;
IF  (@JT  = '8 Company Secretarial')  SET  @return_value = 5;
IF  (@JT  = '984 FS Audit - Newbridge')  SET  @return_value = 1;
IF  (@JT  = '10 Corporate Finance')  SET  @return_value = 2;
IF  (@JT  = '3 Tax Newbridge')  SET  @return_value = 5;
IF  (@JT  = '4 CENTRAL GTFCD')  SET  @return_value = 12;
IF  (@JT  = '161 CENTRAL GTCF')  SET  @return_value = 12;
IF  (@JT  = '947 National Audit & Assurance - Cork')  SET  @return_value = 1;
IF  (@JT  = '943 FAAS Cork')  SET  @return_value = 1;
IF  (@JT  = '988 FS Audit - Limerick')  SET  @return_value = 1;
IF  (@JT  = '983 FS Audit - Dublin')  SET  @return_value = 1;
IF  (@JT  = '103 Limerick Reception')  SET  @return_value = 1;
IF  (@JT  = '600 Business Support')  SET  @return_value = 1;
IF  (@JT  = '5 Tax BMW Galway')  SET  @return_value = 5;
IF  (@JT  = '001 GTFC Dublin')  SET  @return_value = 12;
IF  (@JT  = '164 People & Change')  SET  @return_value = 1;
IF  (@JT  = '110 Corporate Finance Limerick')  SET  @return_value = 2;
IF  (@JT  = '160 BMW Payroll')  SET  @return_value = 5;
IF  (@JT  = 'Belfast-CC Belfast')  SET  @return_value = 1;
IF  (@JT  = 'FAAS')  SET  @return_value = 1;
IF  (@JT  = '630 Internal Finance')  SET  @return_value = 1;
RETURN @return_value
END


