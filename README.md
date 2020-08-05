## IBT Project
![enter image description here](https://www.ibtcollege.com/uploads/4/2/8/8/42885299/published/ibt-no-background_1.png?1567616034)

**Module**: SQL Server

**Teacher**: Eduardo


## Task
It's a project was given to the students who are studying the module SQL SERVER at IBT College and to practice on our skills in to read a statement and build a database based on the *description* below.

## Description 
A patient will have unique Patient ID. Full description about the patient include personal details and phone number, and then Disease and what treatment they are undergoing. Doctors will handle patients; one doctor can treat more than 1 patient. Also, each doctor will have unique ID. Doctor and Patients will be related. Patients can be admitted to hospital. So different room numbers will be there, also rooms for Operation Theaters and ICU. There are some nurses, and ward boys for the maintenance of hospital and for patient take care. Based upon the number of days and treatment bill will be generated.

## Design Decisions and Assumptions
* *Design Decisions* have been made based on the client's description and to find out all tables, constraints, and relationships I have made to try to achieve and cover all points.
* *Assumptions*:
  * '*treatment bill*' - This term was unclear because based on the description the client specified only how many days the patient has stayed there but what more we need to charge. So I have talked with the client (which was the teacher) and we have decided each disease has a different price to be treated.

## Mandatories
* Include two functions
  * Returns a formatted monetary amount depending on the language specified
  * Return the local server time, plus/minus hour

## EDR
[Version 00](https://github.com/FabioVeiga/BDScriptHospital/blob/master/ERD-V0.png?raw=true) |
[Version 01](https://github.com/fabioveiga/BDScriptHospital/blob/master/ERD-v1.png?raw=true)

Current (Version 02)

![EDR](https://github.com/fabioveiga/BDScriptHospital/blob/master/ERD-v2.png?raw=true)