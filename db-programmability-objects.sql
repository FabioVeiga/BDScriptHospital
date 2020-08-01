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

SELECT * FROM Doctor.DoctorXSpecialization
Order by [Name]

DROP VIEW IF EXISTS Patient.QuantityDiseasesXDiseases
GO
CREATE VIEW Patient.QuantityDiseasesXDiseases AS
SELECT
    count(pde.DiseasesID) HowMany, pde.Name
FROM Patient.Treatment AS pt
INNER JOIN Patient.General as pg
    ON pg.PatientID = pt.PatientID
INNER JOIN Patient.Diagnosis as pd
    ON pd.PatientID = pg.PatientID
INNER JOIN Patient.Diseases pde
   ON pde.DiseasesID = pd.DiseasesID
GROUP BY pde.Name

select * from Patient.QuantityDiseasesXDiseases

