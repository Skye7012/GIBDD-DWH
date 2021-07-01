------------------------------------------------------------------------------ 
--çàïðîñ, ñîåäèíÿþùèé âñå òàáëèöû õðàíèëèùà –
--ñ ñîçäàíèåì ïðåäñòàâëåíèÿ è ñ çàïèñüþ ïîëó÷åííûõ äàííûõ â íîâóþ òàáëèöó
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
--5 ðàçíîîáðàçíûõ çàïðîñîâ äëÿ ïîëó÷åíèÿ ñðåçîâ
--êóáà, ñ ïðèìåíåíèåì ãðóïïèðîâîê è àãðåãèðóþùèõ ôóíêöèé 
------------------------------------------------------------------------------
--Ñêîëüêî øòðàôîâ è íà êàêóþ ñóììó åñòü ó âëàäåëüöà àâòîìîáèëÿ ïî ðàçíûì ñòàòüÿì â ïîðÿäêå óáûâàíèÿ ñóììû øòðàôà çà ñòàòüþ? 
select Owner_FIO, Violation_Title, count(Violation_sum) as numOfViolations, sum(Violation_sum) as totalSumOfViolations
From FullFinesTable
Group by Owner_FIO, Violation_Title
Order by 1,4 desc

--Êîëè÷åñòâî íàðóøåíèé è ñóììà øòðàôîâ ïî ñóáúåêòàì
Select Subject_Title,count(Subject_Title) as  numOfViolations, sum(Violation_sum) as totalSumOfFines
From FullFinesTable
Group by Subject_Title
Order by 3 desc,2 desc

--êîëè÷åñòâî íàðóøåíèé ïî ìåñÿöàì çà Íåñîáëþäåíèå òðåáîâàíèé, ïðåäïèñàííûõ äîðîæíûìè çíàêàìè èëè ðàçìåòêîé ïðîåçæåé ÷àñòè äîðîãè, çà èñêëþ÷åíèåì ñëó÷àåâ, ïðåäóñìîòðåííûõ ÷àñòÿìè 2-7 íàñòîÿùåé ñòàòüè è äðóãèìè ñòàòüÿìè íàñòîÿùåé ãëàâû
Select Month(Fine_datetime) as month, count(Month(Fine_datetime)) as numOfViolations
From FullFinesTable
--Where Violation_Title = 'Ñòàòüÿ 12.9 ÷àñòü 2 ÊîÀÏ ÐÔ' OR Violation_Title = 'Ñòàòüÿ 12.9 ÷àñòü 3 ÊîÀÏ ÐÔ'
Where Violation_Title = 'Ñòàòüÿ 12.16 ÷àñòü 1 ÊîÀÏ ÐÔ'
Group By Month(Fine_datetime)
Order By 2 desc,1 

--Íà êàêóþ îáùóþ ñóììó øòðàôîâ çàôèêñèðîâàëà êàæäàÿ êàìåðà íàðóøåíèé çà 2020 ãîä?
Select Camera_location, sum(Violation_sum) as SumOfFines
From FullFinesTable
Where Year(Fine_dateTime) = 2020
Group By (Camera_location)
Order By 2 desc

--Êàêèå ìîäåëè àâòîìîáèëåé ÷àùå âñåãî íàðóøàþò â ïää â êàæäîì ñóáúåêòå?
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
--õðàíèìàÿ ïðîöåäóðà äëÿ ïîëó÷åíèÿ îòäåëüíîé ÿ÷åéêè êóáà
------------------------------------------------------------------------------
--Ñêîëüêî íàðóøåíèé è íà êàêóþ ñóììó áûëî ñîâåðøåííî çà íàðóøåíèå ñòàòüè 12.9 ÷àñòü 2 ÊîÀÏ ÐÔ â Áåëãîðîäñêîé îáëàñòè â ìàå 2020 ãîäà?
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

exec detailFine 'Ñòàòüÿ 12.9 ÷àñòü 2 ÊîÀÏ ÐÔ', 'Áåëãîðîäñêàÿ îáëàñòü', 2020, 5

------------------------------------------------------------------------------
--êðîññ-òàáëèöà ñ ïîìîùüþ êîìàíäû SELECT … PIVOT 
------------------------------------------------------------------------------
--íàðóøåíèé íà êàêóþ ñóììó áûëî çàôèêñèðîâàíî â êàæäîì ðåãèîíå çà êàæäûé ìåñÿö
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

