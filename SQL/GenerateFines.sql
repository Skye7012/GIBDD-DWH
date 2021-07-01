
--зимой чаще штрафуют по нарушениям 7-12, связанным с разметкой. Нарушение скорости в до 40 км/ч самое частое нарушение в принципе. В 2020 году нарушений стало в 12% по сравнению с 2019 и 2018 годами
--нарушений больше в регионах 22,28,76,17,55,33,72
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
		@rand float;

while(@count < 20000)
Begin
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
		set @Camera_id = Floor(Rand()*@Count_cameras + 1); 
		While(@Camera_id != Any(select Camera_id From Camera Where Subject_code in (22,28,76,17,55,33,72)  and @Camera_id = Camera_id))
		begin
			print '4';
			set @Camera_id = Floor(Rand()*@Count_cameras + 1); 
		end
	end
	else 
	begin
		set @Camera_id = Floor(Rand()*@Count_cameras + 1); 
		While(@Camera_id != Any(select Camera_id From Camera Where Subject_code not in (22,28,76,17,55,33,72) and @Camera_id = Camera_id))
		begin
			print '5';
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
