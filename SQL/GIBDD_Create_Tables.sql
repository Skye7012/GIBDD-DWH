CREATE TABLE Owner(
	Owner_id int primary key IDENTITY NOT NULL,
	Owner_FIO varchar(128) NOT NULL,
	Owner_pasport varchar(128) unique not null);

CREATE TABLE CarModel(
	CarModel_id Int Primary key Identity Not null,
	CarModel_manufacturer Varchar(128) Not null, 
	CarModel_title Varchar(128) Not null Unique);

CREATE TABLE Car(
	Car_id int primary key IDENTITY NOT NULL,
	Car_insurance BigInt unique not null,
	CarModel_id Int Not null References CarModel(CarModel_id) On Delete Cascade,
	Owner_id int not null references Owner(Owner_id) on delete cascade);

Create Table Subject(
	Subject_code Int Primary key Not null,
	Subject_Title Varchar(128) Not null Unique);

Create Table Camera(
	Camera_id Int Primary key Identity Not null,
	Camera_location Varchar(256) Not null,
	Subject_code int Not null References Subject(Subject_code) On delete cascade);

Create Table Violation(
	Violation_id Int Primary key Identity Not null,
	Violation_Title Varchar(128) Not null Unique,
	Violation_description Varchar(512) Not null Unique,
	Violation_sum Int Not null);

Create Table Fine(
	Fine_id Int Primary key Identity Not null,
	Fine_dateTime Datetime2(0) Not null,
	Car_id int Not null References Car(Car_id) On delete cascade,
	Violation_id int Not null References Violation(Violation_id) On delete cascade,
	Camera_id int Not null References Camera(Camera_id) On delete cascade);

Create Table FullFinesTable
(
	Id Int Primary Key Identity,
	Car_id Int,
	CarModel_title Varchar(128),
	Owner_FIO  Varchar(128),
	Violation_Title Varchar(128),
	Violation_sum  Int,
	Subject_Title Varchar(128) ,
	Camera_location Varchar(256) ,
	Fine_dateTime datetime 
	--Constraint pk_fines Primary Key(Car_id, Violation_Title, Camera_location, Fine_dateTime)
)