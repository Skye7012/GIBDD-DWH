begin transaction



------------------------------------------------------------------------------------------------
--столбец самая нарушаямая статья КоАП в таблице водителя
------------------------------------------------------------------------------------------------

Alter Table Owner Add MostFrequentlyViolation Varchar(128)
Alter Table Owner Drop Column MostFrequentlyViolation 

Select * From Owner

--заполнение столбца саммая нарушаямая статья КоАП в таблице водителя
go
Create proc fillAlterTableMostFrequentlyViolation
As
	declare @Owner_id int,
			@Violation_Title varchar(128);
Begin
	Declare cur Cursor for Select m.Owner_id, m.Violation_Title From MostFrequentlyViolationView m
	open cur
	Fetch cur into @Owner_id, @Violation_Title
	While @@FETCH_STATUS = 0
	Begin
		Update Owner
		Set MostFrequentlyViolation = @Violation_Title
		Where Owner_id = @Owner_id
		print cast(@Owner_id as varchar) + ', ' + @Violation_Title
		Fetch cur into @Owner_id, @Violation_Title
	End
	deallocate cur
End

exec fillAlterTableMostFrequentlyViolation
drop proc  fillAlterTableMostFrequentlyViolation

------------------------------------------------------------------------------------------------
--столбцы кол-во нарушений и сумма нарушений водителя
------------------------------------------------------------------------------------------------

Alter Table Owner Add numOfViolations Int, totalSumOfViolations Int
Alter Table Owner Drop Column numOfViolations, totalSumOfViolations
Select * From Owner

--заполнение столбцов кол-во нарушений и сумма нарушений водителя
go
Create proc fillAlterTableNumAndSumOfViolations
As
	declare @Owner_id int,
			@numOfViolations Int,
			@totalSumOfViolations Int;
Begin
	Declare cur Cursor for 
		Select Owner_id, Sum(v.numOfViolations), Sum(v.totalSumOfViolations) from Violation_Title_Num_Sum v
		Group by v.Owner_id,v.Owner_FIO
		Order by 1
	open cur
	Fetch cur into @Owner_id, @numOfViolations,@totalSumOfViolations
	While @@FETCH_STATUS = 0
	Begin
		Update Owner
		Set numOfViolations = @numOfViolations
		Where Owner_id = @Owner_id

		Update Owner
		Set totalSumOfViolations = @totalSumOfViolations
		Where Owner_id = @Owner_id

		print cast(@Owner_id as varchar) + ', ' + cast(@numOfViolations as varchar) + ', ' + cast(@totalSumOfViolations as varchar);
		Fetch cur into @Owner_id, @numOfViolations,@totalSumOfViolations
	End
	deallocate cur
End

exec fillAlterTableNumAndSumOfViolations
drop proc  fillAlterTableNumAndSumOfViolations
------------------------------------------------------------------------------------------------
--столбцец рейтинг водителя
------------------------------------------------------------------------------------------------
Alter Table Owner Add Rating varchar(1)
Alter Table Owner Drop Column Rating 
Select * From Owner

--заполнение столбца рейтинг водителя
go
Create proc fillAlterTableRating
As
	declare @Owner_id int,
			@numOfViolations Int,
			@Rating Varchar(128);
Begin
	Declare cur Cursor for 
		Select Owner_id, numOfViolations from Owner
		Order by 1
	open cur
	Fetch cur into @Owner_id, @numOfViolations
	While @@FETCH_STATUS = 0
	Begin
		if(@numOfViolations = 0 OR @numOfViolations is null)
			set @Rating = 'S'
		else if (@numOfViolations <= 5)
			set @Rating = 'A'
		else if (@numOfViolations <= 10)
			set @Rating = 'B'
		else if (@numOfViolations <= 20)
			set @Rating = 'C'
		else 
			set @Rating = 'D'
		Update Owner
				Set Rating = @Rating
				Where Owner_id = @Owner_id
		print cast(@Owner_id as varchar) + ', ' + @Rating;
		Fetch cur into @Owner_id, @numOfViolations
	End
	deallocate cur
End

exec fillAlterTableRating
drop proc  fillAlterTableRating


------------------------------------------------------------------------------------------------
--столбец процент в нарушениях
------------------------------------------------------------------------------------------------

Alter Table Violation Add Perc varchar(6)
Alter Table Violation Drop Column  Perc
Select * From Violation

--заполнение столбца процент в нарушениях

Create proc fillAlterTablePerc
As
	declare @Violation_id Int,
			@numOfFines Int,
			@numOfFinesByViolation Int,
			@perc float,
			@percV varchar(6);
Begin
	select @numOfFines = count(*) from Fine
	Declare cur Cursor for 
		Select Violation_id, Count(Violation_id) from Fine
		Group by Violation_id
		Order by 1
	open cur
	Fetch cur into @Violation_id, @numOfFinesByViolation
	While @@FETCH_STATUS = 0
	Begin
		print @numOfFinesByViolation;
		print @numOfFines;
		set @perc = cast(@numOfFinesByViolation as float)/cast(@numOfFines as float)*100;
		print @perc;
		set @percV = STR(@perc, 5, 2) + '%';  
		Update Violation
		Set Perc = @percV
		Where @Violation_id = Violation_id;
		print @percV
		Fetch cur into @Violation_id, @numOfFinesByViolation
	End
	deallocate cur
End

exec fillAlterTablePerc
drop proc  fillAlterTablePerc


------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------


rollback
commit