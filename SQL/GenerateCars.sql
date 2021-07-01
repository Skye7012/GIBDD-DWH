--45% автомобилей это 1-5 модели, ещё 45% это 6-20 модили, 10% это 21-25 модели. Ранжированние по популярности

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