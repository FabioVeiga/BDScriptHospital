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
    DoctorID INT IDENTITY(1,1) CONSTRAINT PK_DoctorID PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    MiddleName VARCHAR(100) NULL,
    LastName VARCHAR(100) NOT NULL,
    LicenseNumber VARCHAR(20) NOT NULL,
    TypeLicense VARCHAR(50) NOT NULL,
    PhoneNumber1 VARCHAR(11) NOT NULL,
    PhoneNumber2 VARCHAR(11) NULL,
    Signature IMAGE NULL
)

SELECT * FROM Doctor.General

DROP TABLE IF EXISTS Doctor.Specialization
GO

CREATE TABLE Doctor.Specialization(
    SpecializationID INT IDENTITY(1,1) CONSTRAINT PK_SpecializationID PRIMARY KEY,
    Name VARCHAR(100) NOT NULL
)

DROP TABLE IF EXISTS Doctor.DoctorSpecialization
GO

CREATE TABLE Doctor.DoctorSpecialization(
    DoctorSpecializationID INT IDENTITY(1,1) CONSTRAINT PK_DoctorSpecializationID PRIMARY KEY,
    SpecializationID INT,
    DoctorID INT
)

SELECT * FROM Doctor.Specialization

ALTER TABLE Doctor.DoctorSpecialization
ADD CONSTRAINT FK1_SpecializationID_Specialization_DoctorSpecialization
    FOREIGN KEY (SpecializationID)
    REFERENCES Doctor.Specialization (SpecializationID)
GO

ALTER TABLE Doctor.DoctorSpecialization
ADD CONSTRAINT FK2_DoctorID_General
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
    PatientID INT IDENTITY(1,1) CONSTRAINT PK_PatientID PRIMARY KEY,
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
    AddressID INT IDENTITY(1,1) CONSTRAINT PK_AddressID PRIMARY KEY,
    Line1 VARCHAR(MAX) NOT NULL,
    [Number] INT NOT NULL,
    Line2 VARCHAR(MAX) NULL,
    City VARCHAR(50) NOT NULL,
    Province VARCHAR(100) NOT NULL,
    ZipCode VARCHAR(15) NOT NULL,
    PatientID INT
)

ALTER TABLE Patient.Address
ADD CONSTRAINT FX1_PatientID_General_Address
    FOREIGN KEY (PatientID)
    REFERENCES Patient.General(PatientID)
GO

SELECT * FROM Patient.Address

DROP TABLE IF EXISTS Patient.Diseases
GO

CREATE TABLE Patient.Diseases(
    DiseasesID INT IDENTITY(1,1) CONSTRAINT PK_DiseasesID PRIMARY KEY,
    OCD VARCHAR(20) NOT NULL UNIQUE,
    Name VARCHAR(100) NOT NULL,
    Amount DECIMAL(10,2) NULL
)

SELECT * FROM Patient.Diseases

DROP TABLE IF EXISTS Patient.Diagnosis
GO

CREATE TABLE Patient.Diagnosis(
    DiagnosisID INT IDENTITY(1,1) CONSTRAINT PK_DiagnosisID PRIMARY KEY,
    Symptoms VARCHAR(MAX) NOT NULL,
    HealedDate DATE NULL,
    DoctorID INT,
    PatientID INT,
    DiseasesID INT
)

ALTER TABLE Patient.Diagnosis
ADD CONSTRAINT FK1_DoctorID_General_Diagnosis
    FOREIGN KEY (DoctorID)
    REFERENCES Doctor.General(DoctorID)

ALTER TABLE Patient.Diagnosis
ADD CONSTRAINT FK2_PatientID_General_Diagnosis
    FOREIGN KEY (PatientID)
    REFERENCES Patient.General(PatientID)

ALTER TABLE Patient.Diagnosis
ADD CONSTRAINT FK3_DiseasesID_Diseases_Diagnosis
    FOREIGN KEY (DiseasesID)
    REFERENCES Patient.Diseases(DiseasesID)

SELECT * FROM Patient.Diagnosis

DROP TABLE IF EXISTS Patient.Treatment
GO

CREATE TABLE Patient.Treatment(
    TreatmentID INT IDENTITY(1,1) CONSTRAINT PK_TreatmentID PRIMARY KEY,
    Prescription VARCHAR(MAX) NOT NULL,
    DoctorID INT,
    PatientID INT,
    RoomHistoryID INT
)

ALTER TABLE Patient.Treatment
ADD CONSTRAINT FK1_DoctorID_General_Treatment
    FOREIGN KEY (DoctorID)
    REFERENCES Doctor.General(DoctorID)
GO

ALTER TABLE Patient.Treatment
ADD CONSTRAINT FK2_PatientID_General_Treatment
    FOREIGN KEY (PatientID)
    REFERENCES Patient.General(PatientID)
GO

SELECT * FROM Patient.Treatment

/*
    END
*/

/*
    BEGIN
    Create Facilities Schema
    Create Tables
    Create Constraints
*/

DROP SCHEMA IF EXISTS Facilities
GO

CREATE SCHEMA Facilities
GO

DROP TABLE IF EXISTS Facilities.TypeRoom
GO

CREATE TABLE Facilities.TypeRoom(
    TypeRoomID INT IDENTITY(1,1) CONSTRAINT PK_TypeRoom PRIMARY KEY,
    [Name] VARCHAR(100) NOT NULL,
    AmountDaily DECIMAL(10,2) NOT NULL
)

SELECT * FROM Facilities.TypeRoom

DROP TABLE IF EXISTS Facilities.Room
GO

CREATE TABLE Facilities.Room(
    RoomID INT IDENTITY(1,1) CONSTRAINT PK_RoomID PRIMARY KEY,
    NumberRoom INT NOT NULL UNIQUE,
    IsOcuppied Char(1) NOT NULL DEFAULT 'N',
    TypeRoomID INT
)

ALTER TABLE Facilities.Room
ADD CONSTRAINT FK1_TypeRoomID_TypeRoom_Room
    FOREIGN KEY (TypeRoomID)
    REFERENCES Facilities.TypeRoom(TypeRoomID)
GO

DROP TABLE IF EXISTS Facilities.RoomHistory
GO

CREATE TABLE Facilities.RoomHistory(
    RoomHistoryID INT IDENTITY(1,1) CONSTRAINT RoomHistoryID PRIMARY KEY,
    StartDate DATE NOT NULL,
    EndDate DATE NULL,
    RoomID INT
)

ALTER TABLE Facilities.RoomHistory
ADD CONSTRAINT FK1_RoomID_Room_RoomHistory
    FOREIGN KEY (RoomID)
    REFERENCES Facilities.Room(RoomID)
GO

--Add constraint into the table Patient.Treatment
ALTER TABLE Patient.Treatment
ADD CONSTRAINT FK3_RoomHistoryID_RoomHistory_Treatment
    FOREIGN KEY (RoomHistoryID)
    REFERENCES Facilities.RoomHistory(RoomHistoryID)
GO

SELECT * FROM Facilities.RoomHistory

/*
    END
*/

/*
    BEGIN
    Create Bill Schema
    Create Tables
    Create Constraints
*/

DROP SCHEMA IF EXISTS Bill
GO

CREATE SCHEMA Bill
GO

DROP TABLE IF EXISTS Bill.Invoice
GO

CREATE TABLE Bill.Invoice(
    InvoiceID INT IDENTITY(1,1) CONSTRAINT PK_InvoiceID PRIMARY KEY,
    DayOfTreatment INT NOT NULL,
    DiagnosisID INT,
    PatientID INT,
    RoomHistoryID INT
)

ALTER TABLE Bill.Invoice
ADD CONSTRAINT FK1_DiagnosisID_Diagnosis_Invoice
    FOREIGN KEY (DiagnosisID)
    REFERENCES Patient.Diagnosis(DiagnosisID)
GO

ALTER TABLE Bill.Invoice
ADD CONSTRAINT FK2_DoctorID_General_Invoice
    FOREIGN KEY (PatientID)
    REFERENCES Patient.General(PatientID)
GO

ALTER TABLE Bill.Invoice
ADD CONSTRAINT FK3_RoomHistoryID_RoomHistory_Invoice
    FOREIGN KEY (RoomHistoryID)
    REFERENCES Facilities.RoomHistory(RoomHistoryID)
GO

SELECT * FROM Bill.Invoice

/*
    END
*/

/*
    BEGIN
    Create Crew Schema
    Create Tables
    Create Constraints
*/

/*
    END
*/

DROP SCHEMA IF EXISTS Crew
GO

CREATE SCHEMA Crew
GO

DROP TABLE IF EXISTS Crew.Roles
GO

CREATE TABLE Crew.Roles(
    RolesID INT IDENTITY(1,1) CONSTRAINT PK_RolesID PRIMARY KEY,
    [Name] VARCHAR(100) NOT NULL
)

SELECT * FROM Crew.Roles

DROP TABLE IF EXISTS Crew.Employees
GO

CREATE TABLE Crew.Employees(
    EmployeesID INT IDENTITY(1,1) CONSTRAINT PK_EmployeesID PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    MiddleName VARCHAR(100) NULL,
    LastName VARCHAR(100) NOT NULL,
    EarnedPerHour DECIMAL(10,2) NOT NULL,
    RolesID INT
)

ALTER TABLE Crew.Employees
ADD CONSTRAINT FK1_RolesID_Roles_Employees
    FOREIGN KEY (RolesID)
    REFERENCES Crew.Roles(RolesID)
GO

DROP TABLE IF EXISTS Crew.AssistPatient
GO

CREATE TABLE Crew.AssistPatient(
    AssistPatientID INT IDENTITY(1,1) CONSTRAINT PK_AssistPatientID PRIMARY KEY,
    ClockIn DATETIME NOT NULL,
    ClockOut DATETIME NULL,
    EmployeesID INT,
    RoomHistoryID INT,
    PatientID INT
)

ALTER TABLE Crew.AssistPatient
ADD CONSTRAINT FK1_EmployeesID_Employees_AssistPatient
    FOREIGN KEY (EmployeesID)
    REFERENCES Crew.Employees(EmployeesID)
GO

ALTER TABLE Crew.AssistPatient
ADD CONSTRAINT FK2_RoomHistoryID_RoomHistory_AssistPatient
    FOREIGN KEY (RoomHistoryID)
    REFERENCES Facilities.RoomHistory(RoomHistoryID)
GO

ALTER TABLE Crew.AssistPatient
ADD CONSTRAINT FK3_PatientID_General_AssistPatient
    FOREIGN KEY (PatientID)
    REFERENCES Patient.General(PatientID)
GO

/*
    END
*/