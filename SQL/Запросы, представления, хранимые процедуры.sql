------------------------------------------------------------------------------
--запрос, соединяющий все таблицы хранилища –
--с созданием представления и с записью полученных данных в новую таблицу
------------------------------------------------------------------------------
create view FullFinesView AS
select c.Car_id, cm.CarModel_title, o.Owner_FIO, v.Violation_Title, v.Violation_sum,
		s.Subject_Title, cmra.Camera_location, f.Fine_dateTime 
from Owner o Join Car c ON c.Owner_id = o.Owner_id
					Join CarModel cm ON c.CarModel_id = cm.CarModel_id
					Join Fine f ON f.Car_id = c.Car_id 
					JOIN Violation v ON f.Violation_id = v.Violation_id
					JOIN Camera cmra ON f.Camera_id = cmra.Camera_id
					JOIN Subject s ON cmra.Subject_code = s.Subject_code
GO

select * from FullFinesView
order by 1

drop table FullFinesTable

Create Table FullFinesTable
(
	--Id Int Primary Key Identity,
	Car_id Int,
	CarModel_title Varchar(128),
	Owner_FIO  Varchar(128),
	Violation_Title Varchar(128),
	Violation_sum  Int,
	Subject_Title Varchar(128) ,
	Camera_location Varchar(256) ,
	Fine_dateTime datetime 
	Constraint pk_fines Primary Key(Car_id, Violation_Title, Camera_location, Fine_dateTime)
)

Insert INTO FullFinesTable select * from FullFinesView
select * from FullFinesTable
------------------------------------------------------------------------------
--5 разнообразных запросов для получения срезов
--куба, с применением группировок и агрегирующих функций 
------------------------------------------------------------------------------
--Сколько штрафов и на какую сумму есть у владельца автомобиля по разным статьям в порядке убывания суммы штрафа за статью? 
select Owner_FIO, Violation_Title, count(Violation_sum) as numOfViolations, sum(Violation_sum) as totalSumOfViolations
From FullFinesTable
Group by Owner_FIO, Violation_Title
Order by 1,4 desc

--Количество нарушений и сумма штрафов по субъектам
Select Subject_Title,count(Subject_Title) as  numOfViolations, sum(Violation_sum) as totalSumOfFines
From FullFinesTable
Group by Subject_Title
Order by 3 desc,2 desc

--количество нарушений по месяцам за Несоблюдение требований, предписанных дорожными знаками или разметкой проезжей части дороги, за исключением случаев, предусмотренных частями 2-7 настоящей статьи и другими статьями настоящей главы
Select Month(Fine_datetime) as month, count(Month(Fine_datetime)) as numOfViolations
From FullFinesTable
--Where Violation_Title = 'Статья 12.9 часть 2 КоАП РФ' OR Violation_Title = 'Статья 12.9 часть 3 КоАП РФ'
Where Violation_Title = 'Статья 12.16 часть 1 КоАП РФ'
Group By Month(Fine_datetime)
Order By 2 desc,1 

--На какую общую сумму штрафов зафиксировала каждая камера нарушений за 2020 год?
Select Camera_location, sum(Violation_sum) as SumOfFines
From FullFinesTable
Where Year(Fine_dateTime) = 2020
Group By (Camera_location)
Order By 2 desc

--Какие модели автомобилей чаще всего нарушают в пдд в каждом субъекте?
Create View CarViolationsBySubject as
Select CarModel_title, Subject_Title, count(*) as Num
From FullFinesTable 
Group By CarModel_title, Subject_Title
Order By 3 desc
drop view CarViolationsBySubject

Select CarModel_title, Subject_Title, Num
From CarViolationsBySubject c1
Where c1.Num >= All(select c2.Num from CarViolationsBySubject c2 where c1.Subject_Title = c2.Subject_Title)
Order By 3 desc

------------------------------------------------------------------------------
--хранимая процедура для получения отдельной ячейки куба
------------------------------------------------------------------------------
--Сколько нарушений и на какую сумму было совершенно за нарушение статьи 12.9 часть 2 КоАП РФ в Белгородской области в мае 2020 года?
Create proc detailFine
@Violation_Title varchar(128),
@Subject_Title varchar(128),
@year int,
@month int
AS
Select count(*) as  NumOfViolations, sum (Violation_sum) as SumOfFines
From FullFinesTable
Where @Violation_Title = Violation_Title and @Subject_Title = Subject_Title
And @year = year(Fine_dateTime) and @month = month(Fine_dateTime)
GO
drop proc detailFine

exec detailFine 'Статья 12.9 часть 2 КоАП РФ', 'Белгородская область', 2020, 5

------------------------------------------------------------------------------
--кросс-таблица с помощью команды SELECT … PIVOT 
------------------------------------------------------------------------------
--нарушений на какую сумму было зафиксировано в каждом регионе за каждый месяц
Select Subject_Title,
[1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12]  
From
(select Violation_sum, month(Fine_dateTime) as MM, Subject_Title 
 from FullFinesTable) as fuAS
PIVOT
(
sum(Violation_sum)	
For MM IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
) AS pivotTable;
---------------------------------------------
Create view SvTb2 as
select Violation_sum, DATENAME(month, Fine_dateTime) as MM, Subject_Title 
 from FullFinesTable

