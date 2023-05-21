
select * from athlete_events
select * from athletes

select * from athletes a
inner join athlete_events ae on a.id = ae.athlete_id

-- Total_no_of_players
select distinct id from athletes--135,571

-- No_of distinct team
select distinct team from athletes--1,013

-- Total_no_of_distinct_games
select distinct games from athlete_events--51

--Min and Max Year
select Min(year), max(year) from athlete_events -- 1896 MIN & 2016 MAX

--Distinct Season
select distinct season from athlete_events--Summer & Winter

--Distinct Sport
select Distinct Sport from athlete_events--66
--------------------------------------------------------------------------------------------------------------------

--1 which team has won the maximum gold medals over the years.

select top 1 team, count(medal) as count_Gold_medals from athletes a
inner join athlete_events ae on a.id = ae.athlete_id
where medal = 'Gold'
group by team
order by count_Gold_medals desc

--2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns team,total_silver_medals, year_of_max_silver

with cte as
(select a.team, count(ae.medal) as count_Silver_medals, ae.year,
dense_rank() over(partition by a.team order by count(ae.medal)desc) as rank_num
from athletes a
inner join athlete_events ae on a.id = ae.athlete_id
where ae.medal = 'Silver'
group by a.team, ae.year)
--order by count_Silver_medals desc

select team, sum(count_Silver_medals) as total_silver,
max(case when rank_num = 1 then year end) as max_year 
from cte
group by team
order by total_silver desc;

--3 which player has won maximum gold medals amongst the players 
--which have won only gold medal (never won silver or bronze) over the years


select top 1 name from 
(select a.name as name, string_agg(medal, ', ') as gold  from athletes a
inner join athlete_events ae on a.id = ae.athlete_id
where ae.medal!= 'NA'
--where  ae.medal = 'Gold' or ae.medal! ='Silver'  and ae.medal! = 'Bronze' 
group by a.name)t
where gold not like '%Silver%' and gold not like '%Bronze%' 
order by gold desc

--4 in each year which player has won maximum gold medal. Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.

with cte as
(select year, name,  count(ae.medal) as count_Gold_medals,
dense_rank() over(partition by year order by count(ae.medal)desc) as rank_num
from athletes a
inner join athlete_events ae on a.id = ae.athlete_id
where ae.medal = 'Gold'
group by year, name)

select year, STRING_AGG(name, ', ') as Name, count_Gold_medals
from cte 
where rank_num = 1 
group by year, count_Gold_medals;
--order by count_Silver_medals desc


--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport

with cte as (select year, event, medal, 
dense_rank() over(partition by medal order by year) as dense_rk
from athletes a
inner join athlete_events ae on a.id = ae.athlete_id
where team = 'India' and medal ! = 'NA')

select distinct year, medal, event
from cte
where dense_rk =1

--6 find players who won gold medal in summer and winter olympics both.

select name--, count(distinct season)
from athletes a
inner join athlete_events ae on a.id = ae.athlete_id
where medal = 'Gold'
group by name
having count(distinct season) = 2

--7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.

select name--, count(distinct medal) 
from athletes a
inner join athlete_events ae on a.id = ae.athlete_id
where medal! = 'NA'
group by games, name
having count(distinct medal) = 3


--8 find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.

select name -- count(distinct year), STRING_AGG(year, ', ') 
from athletes a
inner join athlete_events ae on a.id = ae.athlete_id
where medal = 'Gold' and Season = 'summer' and year >=2000 --and name = 'Aaron Nguimbat'
group by event,name
having count(distinct year) = 3


