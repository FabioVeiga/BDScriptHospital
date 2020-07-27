USE master
GO

DROP DATABASE IF EXISTS Hospital
GO

CREATE DATABASE Hospital
GO

USE Hospital
GO

/*
    BEGIN
    Create Doctor Schema
    Create Tables
    Create Constraints
*/
DROP SCHEMA IF EXISTS Doctor
GO

CREATE SCHEMA Doctor
GO

DROP TABLE IF EXISTS Doctor.General
GO

CREATE TABLE Doctor.General(
    DoctorID INT IDENTITY(1,1) CONSTRAINT PKDoctorID PRIMARY KEY,
    FisrtName VARCHAR(100) NOT NULL,
    MiddleName VARCHAR(100) NULL,
    LastName VARCHAR(100) NOT NULL,
    LicenseNumber INT NOT NULL,
    TypeLicense VARCHAR(50) NOT NULL,
    PhoneNumber1 VARCHAR(11) NOT NULL,
    PhoneNumber2 VARCHAR(11) NULL,
    Signature IMAGE NULL
)

SELECT * FROM Doctor.General

DROP TABLE IF EXISTS Doctor.Specialization
GO

CREATE TABLE Doctor.Specialization(
    SpecializationID INT IDENTITY(1,1) CONSTRAINT PKSpecializationID PRIMARY KEY,
    Name VARCHAR(100) NOT NULL
)

DROP TABLE IF EXISTS Doctor.DoctorSpecialization
GO

CREATE TABLE Doctor.DoctorSpecialization(
    DoctorSpecializationID INT IDENTITY(1,1) CONSTRAINT PKDoctorSpecializationID PRIMARY KEY,
    SpecializationID INT,
    DoctorID INT
)

SELECT * FROM Doctor.Specialization

ALTER TABLE Doctor.DoctorSpecialization
ADD CONSTRAINT FK1_SpecializationID
    FOREIGN KEY (SpecializationID)
    REFERENCES Doctor.Specialization (SpecializationID)
GO

ALTER TABLE Doctor.DoctorSpecialization
ADD CONSTRAINT FK2_DoctorID
    FOREIGN KEY (DoctorID) 
    REFERENCES Doctor.General(DoctorID)

SELECT * FROM Doctor.DoctorSpecialization

/*
    END
*/

/*
    BEGIN
    Create Patient Schema
    Create Tables
    Create Constraints
*/

DROP SCHEMA IF EXISTS Patient
GO

CREATE SCHEMA Patient
GO

DROP TABLE IF EXISTS Patient.General
GO

CREATE TABLE Patient.General(
    PatientID INT IDENTITY(1,1) CONSTRAINT PKPatientID PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    MiddleName VARCHAR(100) NULL,
    LastName VARCHAR(100) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender CHAR(1) NOT NULL,
    [Weight] Float NULL,
    Height FLOAT NULL,
    PhoneNumber VARCHAR(11) NULL
)

SELECT * FROM Patient.General

DROP TABLE IF EXISTS Patient.Address
GO

CREATE TABLE Patient.Address(
    AddressID INT IDENTITY(1,1) CONSTRAINT PKAddressID PRIMARY KEY,
    Line1 VARCHAR(MAX) NOT NULL,
    Line2 VARCHAR(MAX) NULL,
    City VARCHAR(50) NOT NULL,
    [State] VARCHAR(100) NOT NULL,
    Province VARCHAR(100) NOT NULL,
    ZipCode VARCHAR(15) NOT NULL,
    PatientID INT
)

ALTER TABLE Patient.Address
ADD CONSTRAINT FX1_PatientID
    FOREIGN KEY (PatientID)
    REFERENCES Patient.General(PatientID)
GO

SELECT * FROM Patient.Address

DROP TABLE IF EXISTS Patient.Diseases
GO

CREATE TABLE Patient.Diseases(
    DiseasesID INT IDENTITY(1,1) CONSTRAINT PKDiseasesID PRIMARY KEY,
    OCD VARCHAR(20) NOT NULL UNIQUE,
    Name VARCHAR(100) NOT NULL,
    Amount DECIMAL(10,2) NULL
)

SELECT * FROM Patient.Diseases

DROP TABLE IF EXISTS Patient.Diagnosis
GO

CREATE TABLE Patient.Diagnosis(
    DiagnosisID INT IDENTITY(1,1) CONSTRAINT PKDiagnosisID PRIMARY KEY,
    Symptoms VARCHAR(MAX) NOT NULL,
    HealedDate DATE NULL,
    DoctorID INT,
    PatientID INT,
    DiseasesID INT
)

ALTER TABLE Patient.Diagnosis
ADD CONSTRAINT FK1_DoctorID
    FOREIGN KEY (DoctorID)
    REFERENCES Doctor.General(DoctorID)

ALTER TABLE Patient.Diagnosis
ADD CONSTRAINT FK2_PatientID
    FOREIGN KEY (PatientID)
    REFERENCES Patient.General(PatientID)

ALTER TABLE Patient.Diagnosis
ADD CONSTRAINT FK3_DiseasesID
    FOREIGN KEY (DiseasesID)
    REFERENCES Patient.Diseases(DiseasesID)

SELECT * FROM Patient.Diagnosis

DROP TABLE IF EXISTS Patient.Treatment
GO

CREATE TABLE Patient.Treatment(
    TreatmentID INT IDENTITY(1,1) CONSTRAINT PKTreatmentID PRIMARY KEY,
    Prescription VARCHAR(MAX) NOT NULL,
    DoctorID INT,
    PatientID INT,
    RoomID INT
)

ALTER TABLE Patient.Treatment
ADD CONSTRAINT FK1DoctorID
    FOREIGN KEY (DoctorID)
    REFERENCES Doctor.General(DoctorID)
GO

ALTER TABLE Patient.Treatment
ADD CONSTRAINT FK2PatientID
    FOREIGN KEY (PatientID)
    REFERENCES Patient.General(PatientID)
GO

SELECT * FROM Patient.Treatment

/*
    END
*/
