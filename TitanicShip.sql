

  alter table titanicship
  drop column F18

  select *
  from titanicship


 --Count of Passengers Who Survived vs Did Not Survive ((Survived = 1) and who didn’t (Survived = 0))
  select survived, count(survived) as PassengerCount
  from titanicship
 group by survived

 --survival rate by passenger class
 SELECT Pclass, Count(*) as TotalPassengers, sum(case when survived = 1 then 1 else 0 end ) as Survivors, 
 (SUM(CASE WHEN Survived = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS SurvivalRate
 FROM TitanicShip
 group by Pclass
 order by Pclass

 --Average Age of Survivors vs Non-Survivors
 select Survived, Round(avg(age),2) as AverageAge
 from TitanicShip
 group by Survived

 --survival rate by sex
 select Sex, count(*) as TotalPassengers, sum(case when survived = 1 then 1 else 0 end ) as Survivors, 
 Round(SUM(CASE WHEN Survived = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS SurvivalRate
 from TitanicShip
 group by Sex

 -- survival rate by prefix or title
 select Prefix, count(*) as TotalPassengers, sum(case when survived = 1 then 1 else 0 end ) as Survivors, 
 Round(SUM(CASE WHEN Survived = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS SurvivalRate
 from TitanicShip
 group by Prefix

 --Average Fare by Class and Survival
  select Pclass,survived, count(*) as TotalPassengers, ROUND(avg(fare),2) as AverageFare
 from TitanicShip
 group by Pclass, Survived

 --Passenger Count and Survival Rate by Embarkation Port
  select Embarked, count(*) as TotalPassengers, sum(case when survived = 1 then 1 else 0 end ) as Survivors, 
 Round(SUM(CASE WHEN Survived = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS SurvivalRate
 from TitanicShip
 group by Embarked

 -- Top Fares Paid & Who Paid Them.
 Select top 5 Name, Fare, Pclass, Survived
 from TitanicShip
 order by fare desc

 --Survival Rate by Cabin Availability
 select (case when Cabin = 'N/A' then 'No' else 'Yes' end )as HasCabin, count(*) as TotalPassengers, sum(case when survived = 1 then 1 else 0 end ) as Survivors, 
 Round(SUM(CASE WHEN Survived = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS SurvivalRate
 from TitanicShip
 group by (case when Cabin = 'N/A' then 'No' else 'Yes' end) 
 order by HasCabin

 -- Survival Breakdown by Class and Gender
 select Pclass,Sex, count(*) as TotalPassengers, sum(case when survived = 1 then 1 else 0 end ) as Survivors, 
 Round(SUM(CASE WHEN Survived = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS SurvivalRate
 from TitanicShip
 group by Pclass, sex
 order by Pclass




