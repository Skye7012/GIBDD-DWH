------------------------------------------------------------------------------------------------------------------------------------------------



--45% ����������� ��� 1-5 ������, ��� 45% ��� 6-20 ������, 10% ��� 21-25 ������. ������������� �� ������������

Go
create proc GenerateCars As
Declare @Car_insurance BigInt,
		@Car_model_id int,
		@Owner_id int,
		@count int = 0,
		@rand float;

while(@count < 1000)
Begin
	set @Car_insurance = FLOOR(RAND()*10000000000);
	while @Car_insurance < 1000000000 Or @Car_insurance = Any(select Car_insurance from Car C1 where C1.Car_insurance = @Car_insurance)
	begin
		set @Car_insurance = FLOOR(RAND()*10000000000);
		print @count;
	end
	set @Owner_id = FLOOR(RAND()*1000+1);
	set @rand = Rand()*100;
	if @rand <= 45 
		set @Car_model_id = FLOOR(RAND()*5+1)
	if @rand >45 And @rand <=90 
		set @Car_model_id = FLOOR(RAND()*15+6)
	if @rand >90 And @rand <=100 
		set @Car_model_id = FLOOR(RAND()*5+21)
	INSERT Car VALUES (@Car_insurance, @Car_model_id, @Owner_id);
	set @count = @count + 1;
End
Go

exec GenerateCars
drop proc GenerateCars
delete from Car;
DBCC CHECKIDENT ('Car', RESEED, 0);


Select * from Owner;
Select * from CarModel;
Select * from Car;

Select CarModel_id, count(*) as count
from Car
Group by CarModel_id
Order by CarModel_id



select C1.CarModel_id from CarModel C1
Where Exists(select CarModel_manufacturer, count(*) As count from CarModel C2 Where C1.CarModel_manufacturer = C2.CarModel_manufacturer 
Group by CarModel_manufacturer Having count(*) > 1 )
order by CarModel_id

select CarModel_manufacturer, count(*) As count from CarModel C2
Group by CarModel_manufacturer Having count(*) < 2

Select * from Camera
Where Subject_code = ANY(select Subject_code from Subject)



--------------------------------------------------------------------------------------------------------------------------------------------------------



Select * From Violation

GO
Create proc InsertViolations as
Insert Into Violation 
Values
('������ 12.9 ����� 2 ���� ��','���������� ������������� �������� �������� ������������� �������� �� �������� ����� 20, �� �� ����� 40 ��/�', 500),
('������ 12.9 ����� 3 ���� ��', '���������� ������������� �������� �������� ������������� �������� �� �������� ����� 40, �� �� ����� 60 ��/�', 1000),
('������ 12.9 ����� 4 ���� ��','���������� ������������� �������� �������� ������������� �������� �� �������� ����� 60, �� �� ����� 80 ��/�',2000),
('������ 12.9 ����� 5 ���� ��','���������� ������������� �������� �������� ������������� �������� �� �������� ����� 80 ��/�',5000),
('������ 12.12 ����� 1 ���� ��','������ �� ����������� ������ ��������� ��� �� ����������� ���� �������������, �� ����������� �������, ��������������� ������ 1 ������ 12.10 ���� �� � ������ 2 ��������� ������',1000),
('������ 12.13 ����� 1 ���� ��','����� �� ����������� ��� ����������� �������� ����� ������ � ������ ��������������� ������, ������� ������� �������� ������������, ������ ����������� ��� �������� ������������ ������� � ���������� �����������',1000 ),
('������ 12.12 ����� 2 ���� ��','������������ ���������� ������ ��������� �������� �� ��������� ����� ����-������, ������������ ��������� ������� ��� ��������� �������� ����� ������, ��� ����������� ������� ��������� ��� ����������� ����� �������������',800 ),
('������ 12.15 ����� 3 ���� ��','����� � ��������� ������ ��������� �������� �� ������, ��������������� ��� ���������� ��������, ��� ������� ����������� ���� �� ���������� ���� ���������� ����������� ��� ������� �����������', 1000 ),
('������ 12.15 ����� 4 ���� ��','����� � ��������� ������ ��������� �������� �� ������, ��������������� ��� ���������� ��������, ���� �� ���������� ���� ���������� �����������, �� ����������� �������, ��������������� ������ 3 ��������� ������', 5000 ),
('������ 12.16 ����� 1 ���� ��','������������ ����������, ������������ ��������� ������� ��� ��������� �������� ����� ������, �� ����������� �������, ��������������� ������� 2-7 ��������� ������ � ������� �������� ��������� �����', 500  ),
('������ 12.16 ����� 2 ���� ��','������� ������ ��� �������� � ��������� ����������, ������������ ��������� ������� ��� ��������� �������� ����� ������',1000  ),
('������ 12.16 ����� 4 ���� ��','������������ ����������, ������������ ��������� ������� ��� ��������� �������� ����� ������, ������������ ��������� ��� ������� ������������ �������, �� ����������� ������, ���������������� ������ 5 ��������� ������',  1500);



------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------
--����� ���� �������� �� ���������� 7-12, ��������� � ���������. ��������� �������� � �� 40 ��/� ����� ������ ���������.
--� 2020 ���� ��������� ����� � 12% ������ �� ��������� � 2019 � 2018 ������
--��������� ������ � �������� 22,28,76,17,55,33,72
select * from Fine
select * from Violation
select * from Car

GO
Create proc GenerateFines As
Declare @Fine_dateTime datetime,
		@Fine_year int,
		@Fine_month int,
		@Fine_day int,
		@Car_id int,
		@Count_cars int,
		@Vialation_id int,
		@Camera_id int,
		@Count_cameras int,
		@count int = 0,
		@rand float,
		@Subject_code int; -- del

while(@count < 20000)
Begin
	--set @Fine_year = Floor(Rand()*3+2018);
	select @Count_cars = count(*) from car;
	set @Car_id = FLoor(Rand()*@Count_cars +1);
	set @rand = rand()*100;
	print '1';
	if(@rand <= 40)
		set @Fine_year = 2020;
	else
		set @Fine_year = Floor(Rand()*2+2018);
	set @Fine_month = Floor(Rand()*12+1);
	set @Fine_day = Floor(RAND()*DAY(EOMONTH(DATEFROMPARTS(@Fine_year,@Fine_month,1))) + 1);
	set @Fine_dateTime = DATEFROMPARTS(@Fine_year,@Fine_month,@Fine_day);

	if(@Fine_month =12 OR @Fine_month = 1 OR @Fine_month = 2)
	begin
		set @rand = rand()*100;
		print '2';
			if(@rand <= 30)
				set @Vialation_id = FLOOR(Rand()*6+7);
			else
				set @Vialation_id = FLOOR(Rand()*6+1);
	end
	else
	begin
		set @rand = rand()*100;
			if(@rand <= 80)
				set @Vialation_id = FLOOR(Rand()*2+1);
			else
				set @Vialation_id = FLOOR(Rand()*10+3);
	end

	set @rand = rand()*100;
	print '3';
	select @Count_cameras = count(*) from Camera
	if(@rand <= 25)
	begin
		print '4';
		set @Camera_id = Floor(Rand()*@Count_cameras + 1); 
				select @Subject_code = Subject_code From Camera Where @Camera_id = Camera_id;
		print @Subject_code
		--While(@Camera_id != Any(select Camera_id From Camera Where Subject_code in (22,28,76,17,55,33,72)  and @Camera_id = Camera_id)) ������ ����� ANY �� ��������?
		While(not Exists(select Camera_id From Camera Where Subject_code in (22,28,76,17,55,33,72)  and @Camera_id = Camera_id))
		begin
			set @Camera_id = Floor(Rand()*@Count_cameras + 1); 
				print '44';
		end
			select @Subject_code = Subject_code From Camera Where @Camera_id = Camera_id;
		print @Subject_code
	end
	else 
	begin
		print '5';
		set @Camera_id = Floor(Rand()*@Count_cameras + 1); 
		While(not Exists(select Camera_id From Camera Where Subject_code not in (22,28,76,17,55,33,72) and @Camera_id = Camera_id))
		begin
			print @Count_cameras;
			print  @Camera_id;
			set @Camera_id = Floor(Rand()*@Count_cameras + 1); 
		end
	end
		
	Insert Into Fine Values
	(@Fine_dateTime, @Car_id, @Vialation_id,@Camera_id);

	set @count = @count + 1;
End
GO

exec GenerateFines
drop proc GenerateFines
delete from Fine;
DBCC CHECKIDENT ('Fine', RESEED, 0);

select * from Fine

Select Year(Fine_dateTime) as year, Count(Year(Fine_dateTime)) from Fine Group by Year(Fine_dateTime) Order By Year(Fine_dateTime)

Select Violation_id, count(*) from Fine Group by Violation_id Order By Violation_id

select Subject_code, Camera_id From Camera Where Subject_code in (22,28,76,17,55,33,72) and Camera_id = 1