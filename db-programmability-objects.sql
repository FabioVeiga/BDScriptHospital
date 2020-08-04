USE Hospital

DROP FUNCTION IF EXISTS Patient.BMICalculator
GO
CREATE FUNCTION Patient.BMICalculator (
    @Weight FLOAT,
    @Height FLOAT
)
RETURNS VARCHAR(100) AS
BEGIN
    RETURN 
        CASE
            WHEN @Weight/(@Height*2) > 18.5 THEN 'Underweight'
            WHEN @Weight/(@Height*2) BETWEEN 18.5 AND 18.5 THEN 'Normal'
            WHEN @Weight/(@Height*2) BETWEEN 25.0 AND 29.9 THEN 'Overweight'
            ELSE 'Obese'
        END
END
GO

DROP VIEW IF EXISTS Patient.GeneralInformation
GO
CREATE VIEW Patient.GeneralInformation AS
SELECT
    CONCAT(pg.FirstName, CASE WHEN pg.MiddleName IS NULL THEN '' ELSE ' ' + pg.MiddleName END, ' ',pg.LastName) as [Name],
    CASE 
        WHEN pg.Gender = 'M' THEN 'Male'
        WHEN pg.Gender = 'F' THEN 'Female'
        ELSE 'Other gender'
    END as 'Gender',
    pg.Height,pg.Weight, Patient.BMICalculator(pg.Weight,pg.Height) as BMI,
    pg.DateOfBirth, CONCAT(pa.Number, ', ',Line1, ' ', pa.Line2, ' - ' , pa.Province, ' - ' , pa.City, '(', pa.ZipCode, ')') as [Address]
FROM Patient.General AS pg
INNER JOIN Patient.Address AS pa 
    ON pa.PatientID = pg.PatientID
GO

select * from Patient.GeneralInformation

DROP VIEW IF EXISTS Doctor.DoctorXSpecialization
GO
CREATE VIEW Doctor.DoctorXSpecialization AS
SELECT
    CONCAT(FirstName, CASE WHEN MiddleName IS NULL THEN '' ELSE ' ' + MiddleName END, ' ', LastName) as [Name],
    de.Name AS Specialization
FROM Doctor.General AS dg
INNER JOIN Doctor.DoctorSpecialization AS ds
    ON ds.DoctorID = dg.DoctorID
INNER JOIN Doctor.Specialization AS de
    ON de.SpecializationID = ds.SpecializationID
GO

SELECT * FROM Doctor.DoctorXSpecialization
Order by [Name]

DROP VIEW IF EXISTS Patient.QuantityDiseasesXDiseases
GO
CREATE VIEW Patient.QuantityDiseasesXDiseases AS
SELECT
    count(pde.DiseasesID) HowManyPatientHad, pde.Name as NameDisease
FROM Patient.Treatment AS pt
INNER JOIN Patient.General as pg
    ON pg.PatientID = pt.PatientID
INNER JOIN Patient.Diagnosis as pd
    ON pd.PatientID = pg.PatientID
INNER JOIN Patient.Diseases pde
   ON pde.DiseasesID = pd.DiseasesID
GROUP BY pde.Name
GO

select * from Patient.QuantityDiseasesXDiseases
ORDER BY HowManyPatientHad DESC

DROP PROCEDURE IF EXISTS Patient.InsertNewPatient
GO
CREATE PROCEDURE Patient.InsertNewPatient
    @FisrtName VARCHAR(100),
    @MiddleName VARCHAR(100) = NULL,
    @LastName VARCHAR(100),
    @DateOfBith DATE,
    @Gender CHAR(1),
    @Weight FLOAT,
    @Height FLOAT,
    @PhoneNumber VARCHAR(11) = NULL,
    @Line1 VARCHAR(MAX),
    @Number INTEGER,
    @Line2 VARCHAR(MAX),
    @City VARCHAR(100),
    @Province VARCHAR(100),
    @ZipCode VARCHAR(15)
AS
BEGIN
    BEGIN TRY
        INSERT INTO Patient.General
        (
        [FirstName], [MiddleName], [LastName], [DateOfBirth], [Gender], [Weight], [Height], [PhoneNumber]
        )
        VALUES
        (
        @FisrtName, @MiddleName, @LastName, @DateOfBith, @Gender, @Weight, @Height, @PhoneNumber
        )
        INSERT INTO Patient.Address
        (
        [Line1], [Number], [Line2], [City], [Province], [ZipCode], [PatientID]
        )
        VALUES
        (
        @Line1, @Number, @Line2, @City, @Province, @ZipCode, @@IDENTITY
        )

        SELECT * FROM Patient.General as ge
        JOIN Patient.Address as ad
            ON ad.PatientID = ge.PatientID
        WHERE ad.PatientID = @@IDENTITY

    END TRY
    BEGIN CATCH
        SELECT
            ERROR_NUMBER() AS ErrorNumber  
            ,ERROR_SEVERITY() AS ErrorSeverity  
            ,ERROR_STATE() AS ErrorState  
            ,ERROR_PROCEDURE() AS ErrorProcedure  
            ,ERROR_LINE() AS ErrorLine  
            ,ERROR_MESSAGE() AS ErrorMessage;  
    END CATCH
END
GO

EXEC Patient.InsertNewPatient 'Test', NULL, 'Test', '2000-01-01', 'F', 58.0, 1.56, NULL, 'test', 14, null, 'Quebec', 'Quebec', 'PPPPPPPP'

SELECT * FROM Patient.General as ge
JOIN Patient.Address as ad
    ON ad.PatientID = ge.PatientID
WHERE ad.PatientID = @@IDENTITY

DROP PROCEDURE IF EXISTS Patient.UpdatePatient
GO
CREATE PROCEDURE Patient.UpdatePatient
(
    @PatientID INT,
    @FisrtName VARCHAR(100),
    @MiddleName VARCHAR(100) = NULL,
    @LastName VARCHAR(100),
    @DateOfBith DATE,
    @Gender CHAR(1),
    @Weight FLOAT,
    @Height FLOAT,
    @PhoneNumber VARCHAR(11) = NULL,
    @Line1 VARCHAR(MAX),
    @Number INTEGER,
    @Line2 VARCHAR(MAX),
    @City VARCHAR(100),
    @Province VARCHAR(100),
    @ZipCode VARCHAR(15)
)
AS
BEGIN
    DECLARE @msgOutPut VARCHAR(MAX)

    IF @PatientID IS NULL
        SET @msgOutPut = 'Parameter PatientID cannot be NULL!'
    ELSE
    BEGIN
        IF (SELECT count(*) FROM Patient.General WHERE PatientID = @PatientID) = 0
        BEGIN
            SET @msgOutPut = CONCAT('PatientID: ', @PatientID,' does not exist!')
        END
        ELSE
        BEGIN
            UPDATE Patient.General SET
            FirstName = @FisrtName, MiddleName = @MiddleName, LastName = @LastName,
            DateOfBirth = @DateOfBith, Gender = @Gender, [Weight] = @Weight, Height = @Height,
            PhoneNumber = @PhoneNumber
            WHERE
            PatientID = @PatientID

            UPDATE Patient.Address SET
            Line1 = @Line1, [Number] = @Number, Line2 = @Line2,
            City = @City, Province = @Province, ZipCode = @ZipCode
            WHERE
            PatientID = @PatientID

            SET @msgOutPut = CONCAT('PatientID: ',@PatientID,' has been updated!')
        END
    END
    SELECT @msgOutPut as OutputMsg
END

EXEC Patient.UpdatePatient null, 'Test', NULL, 'Test', '2000-01-01', 'F', 58.0, 1.56, NULL, 'test', 14, null, 'Quebec', 'Quebec', 'PPPPPPPP'
EXEC Patient.UpdatePatient 1003, 'TestUpdate', NULL, 'TestUpdate', '2000-01-01', 'F', 58.0, 1.56, NULL, 'TestUpdate', 14, null, 'Quebec', 'Quebec', 'RRRRRRR'


SELECT * FROM Patient.General as ge
JOIN Patient.Address as ad
    ON ad.PatientID = ge.PatientID
WHERE ad.PatientID = @@IDENTITY

DROP PROCEDURE IF EXISTS Patient.DeletePatient
GO
CREATE PROCEDURE Patient.DeletePatient
(
    @PatientID INT
)
AS
BEGIN
    DECLARE @msgOutPut VARCHAR(MAX)

    IF @PatientID IS NULL
        SET @msgOutPut = 'Parameter PatientID cannot be NULL!'
    ELSE
    BEGIN
        IF (SELECT count(*) FROM Patient.General WHERE PatientID = @PatientID) = 0
        BEGIN
            SET @msgOutPut = CONCAT('PatientID: ', @PatientID,' does not exist!')
        END
        ELSE
        BEGIN
            DELETE FROM Patient.Address WHERE PatientID = @PatientID
            DELETE FROM Patient.General WHERE PatientID = @PatientID
            SET @msgOutPut = CONCAT('PatientID: ',@PatientID,' has been deleted!')
        END
    END
    SELECT @msgOutPut as OutputMsg
END

EXEC Patient.DeletePatient null
EXEC Patient.DeletePatient 1001
EXEC Patient.DeletePatient 1003

SELECT * FROM Patient.General as ge
JOIN Patient.Address as ad
    ON ad.PatientID = ge.PatientID
WHERE ad.PatientID = @@IDENTITY

DROP PROCEDURE IF EXISTS Doctor.InsertDoctor
GO
CREATE PROCEDURE Doctor.InsertDoctor
(
    @FisrtName VARCHAR(100),
    @MiddleName VARCHAR(100) = NULL,
    @LastName VARCHAR(100),
    @LicenseNumber VARCHAR(20),
    @TypeLicense VARCHAR(50),
    @PhoneNumber1 VARCHAR(11),
    @PhoneNumber2 VARCHAR(11),
    @Signature IMAGE
)
AS
BEGIN
    BEGIN TRY
        INSERT INTO Doctor.General (FirstName, MiddleName, LastName, LicenseNumber, TypeLicense, PhoneNumber1, PhoneNumber2, [Signature])
        VALUES (@FisrtName, @MiddleName, @LastName, @LicenseNumber, @TypeLicense, @PhoneNumber1, @PhoneNumber2, @Signature)
        SELECT * FROM Doctor.General WHERE DoctorID = @@IDENTITY
    END TRY
    BEGIN CATCH
        SELECT
            ERROR_NUMBER() AS ErrorNumber  
            ,ERROR_SEVERITY() AS ErrorSeverity  
            ,ERROR_STATE() AS ErrorState  
            ,ERROR_PROCEDURE() AS ErrorProcedure  
            ,ERROR_LINE() AS ErrorLine  
            ,ERROR_MESSAGE() AS ErrorMessage;  
    END CATCH
END

EXECUTE Doctor.InsertDoctor 'John', NULL, 'Smith', '3231', 'Test', NULL, NULL, NULL
EXECUTE Doctor.InsertDoctor 'John', NULL, 'Smith', '3231', 'Test', '11111111', NULL, NULL

SELECT * FROM Doctor.General WHERE DoctorID = 1001

DROP PROCEDURE IF EXISTS Doctor.UpdateDoctor
GO
CREATE PROCEDURE Doctor.UpdateDoctor
(
    @DoctorID INT,
    @FisrtName VARCHAR(100),
    @MiddleName VARCHAR(100) = NULL,
    @LastName VARCHAR(100),
    @LicenseNumber VARCHAR(20),
    @TypeLicense VARCHAR(50),
    @PhoneNumber1 VARCHAR(11),
    @PhoneNumber2 VARCHAR(11),
    @Signature IMAGE
)
AS
BEGIN
    DECLARE @msgOutPut VARCHAR(MAX)
    IF @DoctorID IS NULL
        SET @msgOutPut = 'Parameter DoctorID cannot be NULL!'
    ELSE 
    BEGIN
        IF (SELECT count(*) FROM Doctor.General WHERE DoctorID = @DoctorID) = 0
        BEGIN
            SET @msgOutPut = CONCAT('DoctorID: ', @DoctorID,' does not exist!')
        END
        ELSE
        BEGIN TRY
            UPDATE Doctor.General SET
            FirstName = @FisrtName, MiddleName = @MiddleName, LastName = @LastName,
            LicenseNumber = @LicenseNumber, TypeLicense = @TypeLicense,
            PhoneNumber1 = @PhoneNumber1, PhoneNumber2 = @PhoneNumber2, [Signature] = @Signature
            WHERE
            DoctorID = @DoctorID
            
            SET @msgOutPut = CONCAT('Doctor ',@DoctorID, ' has been updated!')
        END TRY
        BEGIN CATCH
            SELECT
                ERROR_NUMBER() AS ErrorNumber  
                ,ERROR_SEVERITY() AS ErrorSeverity  
                ,ERROR_STATE() AS ErrorState  
                ,ERROR_PROCEDURE() AS ErrorProcedure  
                ,ERROR_LINE() AS ErrorLine  
                ,ERROR_MESSAGE() AS ErrorMessage;  
        END CATCH
    END
    SELECT @msgOutPut as OutputMsg
END
GO

EXECUTE Doctor.UpdateDoctor null, 'John Updated', NULL, 'Smith', '3231', 'Test', NULL, NULL, NULL
EXECUTE Doctor.UpdateDoctor 1001, 'John Updated', NULL, 'Smith', '3231', 'Test', NULL, NULL, NULL
EXECUTE Doctor.UpdateDoctor 1004, 'John Updated', NULL, 'Smith', '3231', 'Test', '11111111', NULL, NULL

SELECT * FROM Doctor.General WHERE DoctorID = 1004

DROP PROCEDURE IF EXISTS Doctor.DeleteDoctor
GO
CREATE PROCEDURE Doctor.DeleteDoctor
(
    @DoctorID INT
)
AS
BEGIN
    DECLARE @msgOutPut VARCHAR(MAX)

    IF @DoctorID IS NULL
        SET @msgOutPut = 'Parameter DoctorID cannot be NULL!'
    ELSE
    BEGIN
        IF (SELECT count(*) FROM Doctor.General WHERE DoctorID = @DoctorID) = 0
        BEGIN
            SET @msgOutPut = CONCAT('DoctorID: ', @DoctorID,' does not exist!')
        END
        ELSE
        BEGIN
            DELETE FROM Doctor.General WHERE DoctorID = @DoctorID
            SET @msgOutPut = CONCAT('DoctorID: ',@DoctorID,' has been deleted!')
        END
    END
    SELECT @msgOutPut as OutputMsg
END

EXECUTE Doctor.DeleteDoctor NULL
EXECUTE Doctor.DeleteDoctor 1001
EXECUTE Doctor.DeleteDoctor 1004


-- Mandatory Functions
DROP FUNCTION IF EXISTS FormatMonetary
GO
CREATE FUNCTION FormatMonetary
(
    @Value DECIMAL(10,2),
    @Language VARCHAR(2)
)
RETURNS VARCHAR(MAX) AS
BEGIN
    RETURN
        CASE
            WHEN LOWER(@Language) = 'fr' THEN CONCAT(@Value,' $')
            WHEN LOWER(@Language) = 'en' THEN CONCAT('$ ' ,@Value)
            ELSE CONCAT(@Language, ' does not exist!')
        END
END
GO

SELECT dbo.FormatMonetary(12.42, 'en')
UNION
SELECT dbo.FormatMonetary(12.42, 'fr')
UNION
SELECT dbo.FormatMonetary(12.42, 'pt')


DROP FUNCTION IF EXISTS func_getTime
GO
CREATE FUNCTION func_getTime
(
    @Time TIME,
    @input INT
)
RETURNS VARCHAR(100) AS
BEGIN
    RETURN
        CONVERT(varchar, DATEADD(HOUR, @input, @Time), 100)
END
GO

SELECT dbo.func_getTime('9:00pm', -3)
UNION ALL
SELECT dbo.func_getTime('9:00pm',3)

