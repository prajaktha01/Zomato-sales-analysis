use insurance;

select * from invoice;

# 1-No of Invoice by Accnt Exec
select Account_Executive, 
sum(case when income_class ="new" then 1 else 0 end) as "New", 
sum(case when income_class="Cross sell" then 1 else 0 end) as "Cross_Sell", 
sum(case when income_class ="Renewal" then 1 else 0 end) as "Renewal", 
count(invoice_date) as Total from invoice group by 1 order by 5 asc;

select * from meeting;

# 2-Yearly Meeting Count
select year(meeting_date) as Yr, count(meeting_date) as Total_Meeting from meeting group by 1 order by 1 desc;

# No. of meeting for the current year
select count(year(meeting_date)) as Total_Meeting, count(case when year(meeting_date) = "2020" then 1 end) as Current_Year_Meeting from meeting;

# 5. No of meeting By Account Exe
select account_executive, count(meeting_date) as Total_Meeting from meeting group by 1 order by 2 desc;

select * from opportunity;

# 4. Stage Funnel by Revenue
select stage, sum(revenue_amount) as Total_Revenue from opportunity group by 1 order by 2 desc;

# 6. Top 4 Open Opportunity
select opportunity_name, sum(revenue_amount) as Total_Revenue from opportunity where stage <> "Negotiate" group by 1 order by 2 desc limit 4;

# Top 10 Open Opportunity
select opportunity_name, revenue_amount from opportunity where stage <> "Negotiate" order by 2 desc , 1 asc limit 10;

# Open Oppty (Stage ‘Open’ Column Value = Propose Solution & Qualify Opportunity)
select opportunity_name, stage, revenue_amount from opportunity where stage <> "Negotiate";
select stage, sum(revenue_amount) as Total_Amount from opportunity where stage <> "Negotiate" group by 1;

# Total Open & Total Opportunity
select count(opportunity_name) as Total_Opportunity, count(case when stage <> "Negotiate" then 1 end) as Total_Open_Opportunity from opportunity;


select * from budgets;

# Target FY from Individual Budget sheet (New, Cross sell and Renewal) 

select sum(cross_sell_bugdet) as Cross_Sell_Target, sum(new_budget) as New_Target, sum(Renewal_Budget) as Renewal_Target from budgets;

# Placed Achievement form Brokerage + Fees sheet (New, Cross sell and Renewal) 

select * from fees;
select * from brokerage;

select income_class, sum(total) as Placed_Achievement from 
(select income_class, round(sum(amount), 2) as total from brokerage where income_class in ("New","Cross Sell","Renewal") group by 1
union all
select income_class, sum(amount) as total from fees group by 1) as a group by 1; 

# Invoiced Achievement from Invoice sheet (New, Cross sell and Renewal) 

select * from invoice;

select income_class, sum(amount) as Invoiced_Achievement from invoice group by 1;

# Percentage of Achievement for Placed and Invoice – (Achieved/budget)

# Long Version----

create view task1 as select sum(cross_sell_bugdet) as Cross_Sell_Target, sum(new_budget) as New_Target, sum(Renewal_Budget) as Renewal_Target from budgets;

create view task2 as select income_class, sum(total) as Placed_Achievement from (select income_class, round(sum(amount), 2) as total from brokerage 
where income_class in ("New","Cross Sell","Renewal") group by 1
union all
select income_class, sum(amount) as total from fees group by 1) as a group by 1;

create view task3 as select income_class, sum(amount) as Invoiced_Achievement from invoice group by 1;

create view task4 as select income_class, 
case when income_class = "Cross Sell" then concat(round((Placed_Achievement/(select cross_sell_target from task1))*100,2),"%") 
when income_class = "New" then concat(round((Placed_Achievement/(select New_target from task1))*100,2),"%") 
else concat(round((Placed_Achievement/(select Renewal_target from task1))*100,2),"%") end as Placed_Percent
from task2; 

create view task5 as select income_class,
case when income_class = "Cross Sell" then concat(round((Invoiced_Achievement/(select cross_sell_target from task1))*100,2),"%") 
when income_class = "New" then concat(round((Invoiced_Achievement/(select New_target from task1))*100,2),"%") 
else concat(round((Invoiced_Achievement/(select Renewal_target from task1))*100,2),"%") end as Invoiced_Percent from task3;

select a.income_class, a.Placed_Percent, b.Invoiced_Percent from task4 as a join task5 as b on a.income_class=b.income_class;

# Short Version -----

WITH task1 AS (
    SELECT SUM(cross_sell_bugdet) AS Cross_Sell_Target, SUM(new_budget) AS New_Target, 
    SUM(Renewal_Budget) AS Renewal_Target FROM budgets
),

task2 AS (
    SELECT income_class, SUM(total) AS Placed_Achievement FROM 
    (
    SELECT income_class, ROUND(SUM(amount), 2) AS total FROM brokerage 
    WHERE income_class IN ('New', 'Cross Sell', 'Renewal')
    GROUP BY income_class
	
    UNION ALL

	SELECT income_class, SUM(amount) AS total FROM fees WHERE income_class IN ('New', 'Cross Sell', 'Renewal') GROUP BY income_class
    ) AS combined GROUP BY income_class
),

task3 AS (
    SELECT income_class, SUM(amount) AS Invoiced_Achievement FROM invoice WHERE income_class IN ('New', 'Cross Sell', 'Renewal')
    GROUP BY income_class),
final AS (
    SELECT t2.income_class,
        CONCAT(ROUND(
            CASE WHEN t2.income_class = 'Cross Sell' THEN (t2.Placed_Achievement / t1.Cross_Sell_Target) * 100
                 WHEN t2.income_class = 'New' THEN (t2.Placed_Achievement / t1.New_Target) * 100
                 ELSE (t2.Placed_Achievement / t1.Renewal_Target) * 100
            END, 2),"%") AS Placed_Percent,
CONCAT(ROUND(CASE WHEN t3.income_class = 'Cross Sell' THEN (t3.Invoiced_Achievement / t1.Cross_Sell_Target) * 100
                 WHEN t3.income_class = 'New' THEN (t3.Invoiced_Achievement / t1.New_Target) * 100
                 ELSE (t3.Invoiced_Achievement / t1.Renewal_Target) * 100
            END, 2),"%") AS Invoiced_Percent FROM task1 as t1 CROSS JOIN task2 as t2 
            JOIN task3 t3 ON t2.income_class = t3.income_class)
SELECT * FROM final;


select * from fees;
select * from brokerage;
select * from invoice;
select * from budgets;

# 3.1 Cross Sell-Target,Achive,new
# 3.1 New-Target,Achive,new
# 3.1 Renewal-Target, Achive,new

with task1 as (select sum(new_budget) as New_Target, sum(cross_sell_bugdet) as Cross_Sell_Target, sum(renewal_budget) as Renewal_Target from budgets),

task2 as (select income_class, round(sum(total),2) as Placed_Achievement from 
(
select income_class, sum(amount) as total from brokerage where income_class in ("New", "Cross Sell","Renewal") group by 1
union all
select income_class, sum(amount) as total from fees group by 1
) as combined group by 1),

task3 as (select income_class, sum(amount) as Invoiced_Achievement from invoice group by 1),

final as (select b.Income_Class, 
(case when b.income_class = "New" then a.New_Target 
when b.income_class = "Cross Sell" then a.Cross_Sell_Target 
else a.Renewal_Target end) as Target, 
b.Placed_Achievement, c.Invoiced_Achievement from task1 as a cross join task2 as b join task3 as c on b.income_class=c.income_class )

select * from final;




# For Individual output

# 3.1 Cross Sell-Target,Achive,new

WITH task1 AS (SELECT SUM(cross_sell_bugdet) AS Cross_Sell_Target FROM budgets),

task2 AS (SELECT SUM(total) AS Placed_Achievement FROM 
		 (SELECT SUM(amount) AS total FROM brokerage WHERE income_class = 'Cross Sell'
		  UNION ALL
          SELECT SUM(amount) FROM fees WHERE income_class = 'Cross Sell') 
	  AS combined),
      
task3 AS (SELECT SUM(amount) AS Invoiced_Achievement FROM invoice WHERE income_class = 'Cross Sell')

SELECT 'Target' AS Total, t1.Cross_Sell_Target AS "Cross Sell" FROM task1 t1
UNION ALL
SELECT 'Achieved', round(t2.Placed_Achievement,2) FROM task2 t2
UNION ALL
SELECT 'Invoice', t3.Invoiced_Achievement FROM task3 t3;

# 3.1 New-Target,Achive,new

WITH task1 AS (SELECT SUM(New_budget) AS New_Target FROM budgets),

task2 AS (SELECT SUM(total) AS Placed_Achievement FROM 
		 (SELECT SUM(amount) AS total FROM brokerage WHERE income_class = 'New'
		  UNION ALL
          SELECT SUM(amount) FROM fees WHERE income_class = 'New') 
	  AS combined),
      
task3 AS (SELECT SUM(amount) AS Invoiced_Achievement FROM invoice WHERE income_class = 'New')

SELECT 'Target' AS Total, t1.New_Target AS "New" FROM task1 t1
UNION ALL
SELECT 'Achieved', round(t2.Placed_Achievement,2) FROM task2 t2
UNION ALL
SELECT 'Invoice', t3.Invoiced_Achievement FROM task3 t3;

# 3.1 Renewal-Target, Achive,new

WITH task1 AS (SELECT SUM(Renewal_Budget) AS Renewal_Target FROM budgets),

task2 AS (SELECT SUM(total) AS Placed_Achievement FROM 
		 (SELECT SUM(amount) AS total FROM brokerage WHERE income_class = 'Renewal'
		  UNION ALL
          SELECT SUM(amount) FROM fees WHERE income_class = 'Renewal') 
	  AS combined),
      
task3 AS (SELECT SUM(amount) AS Invoiced_Achievement FROM invoice WHERE income_class = 'Renewal')

SELECT 'Target' AS Total, t1.Renewal_Target AS "Renewal" FROM task1 t1
UNION ALL
SELECT 'Achieved', round(t2.Placed_Achievement,2) FROM task2 t2
UNION ALL
SELECT 'Invoice', t3.Invoiced_Achievement FROM task3 t3;

























# New

with task1 as (select sum(new_budget) as New_Target from budgets),

task2 as (select income_class, round(sum(total),2) as Placed_Achievement from 
(
select income_class, sum(amount) as total from brokerage where income_class = "New" 
union all
select income_class, sum(amount) as total from fees where income_class = "New"
) as combined group by 1),

task3 as (select income_class, sum(amount) as Invoiced_Achievement from invoice where income_class = "New" group by 1),

final as (select  b.Income_Class, a.New_Target as Target, b.Placed_Achievement, c.Invoiced_Achievement from task1 as a cross join task2 as b join task3 as c on b.income_class=c.income_class )

select * from final;



# Renewal

with task1 as (select sum(Renewal_budget) as Renewal_Target from budgets),

task2 as (select income_class, round(sum(total),2) as Placed_Achievement from 
(
select income_class, sum(amount) as total from brokerage where income_class = "Renewal" 
union all
select income_class, sum(amount) as total from fees where income_class = "Renewal"
) as combined group by 1),

task3 as (select income_class, sum(amount) as Invoiced_Achievement from invoice where income_class = "Renewal" group by 1),

final as (select  b.Income_Class, a.Renewal_Target as Target, b.Placed_Achievement, c.Invoiced_Achievement from task1 as a cross join task2 as b join task3 as c on b.income_class=c.income_class )

select * from final;



# Cross Sell

with task1 as (select sum(Cross_Sell_bugdet) as Cross_Sell_Target from budgets),

task2 as (select income_class, round(sum(total),2) as Placed_Achievement from 
(
select income_class, sum(amount) as total from brokerage where income_class = "Cross Sell" 
union all
select income_class, sum(amount) as total from fees where income_class = "Cross Sell"
) as combined group by 1),

task3 as (select income_class, sum(amount) as Invoiced_Achievement from invoice where income_class = "Cross Sell" group by 1),

final as (select  b.Income_Class, a.Cross_Sell_Target as Target, b.Placed_Achievement, c.Invoiced_Achievement from task1 as a cross join task2 as b join task3 as c on b.income_class=c.income_class )

select * from final;