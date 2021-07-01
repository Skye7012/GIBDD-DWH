use GIBDD
SET DATEFORMAT ymd; 
---------------------------------------------------
exec sp_MSforeachtable 'SELECT * FROM ?'

begin transaction
rollback
DBCC CHECKIDENT (match, RESEED, 4);
commit 
---------------------------------------------------
Drop Table Fine;
Drop Table Violation;
Drop Table Car;
Drop Table Owner;
Drop Table CarModel;
Drop Table Camera;
Drop Table Subject;
---------------------------------------------------
delete from Subject;
DBCC CHECKIDENT ('Subject', RESEED, 0);
delete from Owner;
DBCC CHECKIDENT ('Owner', RESEED, 0);
delete from Camera;
DBCC CHECKIDENT ('Camera', RESEED, 0);
delete from Car;
DBCC CHECKIDENT ('Car', RESEED, 0);
---------------------------------------------------
select * from FullFinesTable
Select * from Fine;
Select * from Owner;
Select * from CarModel;
Select * from Car;
Select * from Violation;
Select * from Subject;
Select * from Camera;