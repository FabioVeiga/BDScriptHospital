USE master
GO

DROP DATABASE IF EXISTS Hospital
GO

CREATE DATABASE Hospital
go

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
    DoctorID INT IDENTITY(1,1) PRIMARY KEY,
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
    SpecializationID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL
)

DROP TABLE IF EXISTS Doctor.DoctorSpecialization
GO

CREATE TABLE Doctor.DoctorSpecialization(
    DoctorSpecializationID INT IDENTITY(1,1) PRIMARY KEY,
    SpecializationID INT,
    DoctorID INT
)

ALTER TABLE Doctor.DoctorSpecialization
ADD CONSTRAINT FK1_SpecializationID FOREIGN KEY (SpecializationID)
    REFERENCES Doctor.Specialization (SpecializationID)
GO

ALTER TABLE Doctor.DoctorSpecialization
ADD CONSTRAINT FK2_DoctorID
FOREIGN KEY (DoctorID) REFERENCES Doctor.General(DoctorID)

SELECT * FROM Doctor.Specialization
SELECT * FROM Doctor.DoctorSpecialization

/*
    END
*/
