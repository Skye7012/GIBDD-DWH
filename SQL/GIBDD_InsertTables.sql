bcp GIBDD.dbo.Owner in "C:\Users\Rashit\Documents\Study\4 סולוסענ\ÕÄ\source\Owners.txt" -T -S DESKTOP-BDT1AGL -C 1251 -t; -c
bcp GIBDD.dbo.Subject in "C:\Users\Rashit\Documents\Study\4 סולוסענ\ÕÄ\source\Subjects.txt" -T -S DESKTOP-BDT1AGL -C 1251 -t; -c
bcp GIBDD.dbo.Camera in "C:\Users\Rashit\Documents\Study\4 סולוסענ\ÕÄ\source\Cameras.txt" -T -S DESKTOP-BDT1AGL -C 1251 -t"||" -c 
bcp GIBDD.dbo.CarModel in "C:\Users\Rashit\Documents\Study\4 סולוסענ\ÕÄ\source\CarModels.txt" -T -S DESKTOP-BDT1AGL -C 1251 -t; -c 
exec GenerateCars
exec InsertViolations
exec GenerateFines
