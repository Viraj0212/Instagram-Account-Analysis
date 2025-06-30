SELECT * FROM gdb0120.fact_content;
-- How many unique post types are found in the 'fact_content' table?
SELECT distinct post_type From fact_content;
-- 2. What are the highest and lowest recorded impressions for each post type?
SELECT post_type,(impressions) as max,MIN(impressions) as min From fact_content group by post_type;
-- 3. Filter all the posts that were published on a weekend in the month of March and April and export them to a separate csv file.
Select * from fact_content f join dim_dates d on f.date=d.date where weekday_or_weekend="weekend" and month_name IN ("March","April");
-- Create a report to get the statistics for the account. The final output includes the following fields:
-- • month_name
-- • total_profile_visits
-- • total_new_followers
select * from dim_dates d join fact_account f on d.date=f.date;
-- 1
select d.month_name,SUM(f.profile_visits) as Total_profile_visits,SUM(f.new_followers) as Total_new_followers  from dim_dates d join fact_account f on d.date=f.date group by d.month_name;
-- Write a CTE that calculates the total number of 'likes’ for each 'post_category' during the month of 'July' and subsequently, arrange the 'post_category' values in descending order according to their total likes. 
select post_category,SUM(likes) as Total_likes from fact_content f join dim_dates d on f.date=d.date where month_name="July" group by post_category order by Total_likes DESC;
-- 2
WITH post_category_like AS (select f.post_category,SUM(f.likes) as Total_likes from fact_content f join dim_dates d on f.date=d.date where d.month_name='July' group by post_category)
SELECT 
    post_category,
    total_likes
FROM 
    post_category_like
ORDER BY 
    total_likes DESC;
    
-- 6. Create a report that displays the unique post_category names alongside their respective counts for each month. The output should have three columns:
-- •
-- month_name
-- •
-- post_category_names
-- •
-- post_category_count
-- Example:
-- •
-- 'April', 'Earphone,Laptop,Mobile,Other Gadgets,Smartwatch', '5'
-- • 'February', 'Earphone,Laptop,Mobile,Smartwatch', '4'
select d.month_name,GROUP_CONCAT(distinct post_category ORDER BY post_category SEPARATOR ',') as post_category,COUNT(distinct post_category) AS category_count from fact_content f join dim_dates d on f.date=d.date group by month_name;
-- 7.
-- What is the percentage breakdown of total reach by post type? The final output includes the following fields:
-- •
-- post_type
-- •
-- total_reach
-- • reach_percentage
select post_type,sum(reach) as Total_reach,ROUND(SUM(reach) * 100.0 / (select SUM(reach) FROM fact_content), 2) AS reach_percentage from fact_content group by post_type;
-- The final output columns should consist of:
-- •
-- post_category
-- •
-- quarter
-- •
-- total_comments
-- •
-- total_saves
select * from dim_dates;
ALTER TABLE dim_dates
ADD COLUMN quarter VARCHAR(10);
SET SQL_SAFE_UPDATES = 0;
UPDATE dim_dates
SET quarter = CASE
    WHEN month_name IN ('January', 'February', 'March') THEN 'Q1'
    WHEN month_name IN ('April', 'May', 'June') THEN 'Q2'
    WHEN month_name IN ('July', 'August', 'September') THEN 'Q3'
    ELSE 'Q4'  
END;
SET SQL_SAFE_UPDATES = 1;
select * from dim_dates;
select f.post_category,quarter,(f.comments) as Total_Comments,SUM(saves) as Total_Saves from fact_content f join dim_dates d on f.date=d.date group by post_category,quarter;
-- List the top three dates in each month with the highest number of new followers. The final output should include the following columns: 
-- month 
-- date 
-- new_followers 

SELECT month_name,date,new_followers
FROM (
    SELECT 
        d.month_name,
        f.date,
        s.new_followers,
        ROW_NUMBER() OVER (PARTITION BY d.month_name ORDER BY s.new_followers DESC) AS rn
    FROM fact_content f
    JOIN dim_dates d ON f.date = d.date
    JOIN fact_account s ON f.date = s.date
) t
WHERE rn <= 3
ORDER BY month_name,new_followers DESC;
-- 10.
-- Create a stored procedure that takes the 'Week_no' as input and generates a report displaying the total shares for each 'Post_type'. The output of the procedure should consist of two columns:
-- •
-- post_type
-- •
-- total_shares
call gdb0120.Get_Shares_ByWeek('W15');
