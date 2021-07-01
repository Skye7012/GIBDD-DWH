begin transaction
rollback

------------------------------------------------------------------------------------------------
--удаляем штрафы за ненужные года
------------------------------------------------------------------------------------------------
select * from FullFinesTable
Where Year(Fine_dateTime) not in (2019,2020)

Delete from FullFinesTable
Where Year(Fine_dateTime) not in (2019,2020)

Delete from FullFinesTable

------------------------------------------------------------------------------------------------
--проверка фио, чтобы были как минимум Имя и Фамилия
------------------------------------------------------------------------------------------------
update FullFinesTable
set Owner_FIO = 'aa'
where Car_id = 1

select * from FullFinesTable
where charindex(' ', Owner_FIO) = 0

Delete from FullFinesTable
where charindex(' ', Owner_FIO) = 0

------------------------------------------------------------------------------------------------
--таблица аналогичная штрафам, но с кол-вом штрафов и общей суммой штрафов, с самой нарушаемой статьей и с годом, в котором было больше всего нарушений
--и с наличием людей добропорядочных (без штрафов)
------------------------------------------------------------------------------------------------

Create table FineStatistics(
	Id Int Identity Primary key,
	Owner_id Int,
	Owner_FIO Varchar(128),
	MostFrequentViolation Varchar(128),
	FinesNum Int,
	FinesSum Int,
	MostViolationYear Int);

drop table FineStatistics

select * from FineStatistics

--Сколько штрафов и на какую сумму есть у владельца автомобиля по разным статьям в порядке убывания суммы штрафа за статью? 
go
Create View  Violation_Title_Num_Sum
As
select o.Owner_id,f.Owner_FIO, f.Violation_Title, count(f.Violation_sum) as numOfViolations, sum(f.Violation_sum) as totalSumOfViolations
From FullFinesTable f 
Join Car c On c.Car_id = f.Car_id
Join Owner o On c.Owner_id = o.Owner_id
Group by o.Owner_id,f.Owner_FIO, f.Violation_Title
Order by 1,4 desc
 
drop view Violation_Title_Num_Sum

Select * from Violation_Title_Num_Sum

--саммая нарушаямая статья КоАП по водителям
select * from Violation_Title_Num_Sum vT
Where vT.numOfViolations = (select max(vt2.numOfViolations) from Violation_Title_Num_Sum vT2 where vT.Owner_id= vt2.Owner_id)
Order by 1

--сколько нарушаений у автомобилиста в каждом году
Create View ViolationPerYearByOwner
As
Select o.Owner_id,f.Owner_FIO, count(f.Violation_sum) as numOfViolations, year(f.Fine_dateTime) as V_Year
From FullFinesTable f 
Join Car c On c.Car_id = f.Car_id
Join Owner o On c.Owner_id = o.Owner_id
Group by o.Owner_id,f.Owner_FIO, year(f.Fine_dateTime)
Order by 1 

Drop view ViolationPerYearByOwner

Create View MostViolationYearByOwner
As
Select * from ViolationPerYearByOwner vY
Where vY.numOfViolations = (select max(vY2.numOfViolations) from ViolationPerYearByOwner vY2 where vY.Owner_id= vY2.Owner_id)
Order by 1


select * from FineStatistics
Order by 2

Insert Into FineStatistics
	Select vT.Owner_id, vT.Owner_FIO, vT.Violation_Title,vT.numOfViolations, vT.totalSumOfViolations, mY.V_Year From Violation_Title_Num_Sum vT
	JOIN MostViolationYearByOwner mY On mY.Owner_id = vT.Owner_Id
	Where vT.numOfViolations = (select max(vt2.numOfViolations) from Violation_Title_Num_Sum vT2 where vT.Owner_id= vt2.Owner_id)
	Order By 1

Insert Into FineStatistics
	Select o.Owner_id, o.Owner_FIO, null,0,0,null From Owner o
	Where o.Owner_id not in (Select Owner_id From Violation_Title_Num_Sum)

Select * from Owner o
Where o.Owner_id not in (Select Owner_id From Violation_Title_Num_Sum)
------------------------------------------------------------------------------------------------
--проверка правильности введеденой модели автомобиля и исправление
------------------------------------------------------------------------------------------------
SET DATEFORMAT ymd; 

Select * from FullFinesTable

Update FullFinesTable
Set CarModel_title = null
where Fine_dateTime = '2018-01-15'

Update FullFinesTable
Set CarModel_title = 'aa'
where Fine_dateTime = '2018-01-15'

go
Create proc FixWrongCarModelTitle
As
	declare @Car_id Int, 
	@CarModel_title VarChar(128),
	@RightCarModel_title VarChar(128),
	@Msg Varchar(128);
Begin
	DECLARE cur CURSOR FOR  SELECT Car_id, CarModel_title FROM FullFinesTable
	OPEN cur
	FETCH cur INTO @Car_id, @CarModel_title
	WHILE @@FETCH_STATUS = 0
	BEGIN
		select @RightCarModel_title = CarModel_title From CarModel cm Join Car c ON c.CarModel_id = cm.CarModel_id Where c.Car_id = @Car_id
		if(@CarModel_title is null OR @CarModel_title != @RightCarModel_title)
			Begin
			print ('Было:' + isnull(@CarModel_title,'Null') + ', Стало: ' + @RightCarModel_title);
			Update FullFinesTable
			Set CarModel_title = @RightCarModel_title
			Where Car_id = @Car_id And (CarModel_title = @CarModel_title OR CarModel_title is null);
			End
		FETCH cur INTO @Car_id, @CarModel_title
	END
   Deallocate cur
End

drop proc FixWrongCarModelTitle
exec FixWrongCarModelTitle

Select * from FullFinesTable f
where CarModel_title is null
