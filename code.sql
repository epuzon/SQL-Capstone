 --1) Select the first and latest subscription start dates. 
 
 SELECT MIN(subscription_start) AS 'company_subscription_start', MAX(subscription_start) AS 'latest_subscription_start'
 FROM subscriptions;
 
--2) Select the types of segments on the table. 

SELECT DISTINCT segment AS 'users'
FROM subscriptions
LIMIT 10; 

--3) Create a new table showing the months can be utilized to calculate the churn rate. 
 WITH months AS (
	SELECT '2017-01-01' AS first_day,
 	'2017-01-31' AS last_day
  UNION
  SELECT '2017-02-01' AS first_day, 
	'2017-02-28' AS last_day
  UNION
  SELECT '2017-03-01' AS first_day, 
	'2017-03-30' AS last_day
 ),
 --Join the subscriptions table and months table into a temporary table called "cross_join"
cross_join AS (
 	SELECT *
 	FROM subscriptions
 	CROSS JOIN months), 
--Create status table from the cross_join table. 
status AS (
 SELECT id, first_day AS 'month', 
		CASE WHEN (subscription_start < first_day)
		AND (subscription_end > first_day OR subscription_end IS NULL)
  	AND (segment = 87)
  	THEN 1
  	ELSE 0
 		END AS 'is_active_87', 
--Statement above states that IF value of subscription date is less than the beginning of the month (subscription started before the given month) and subscription end date value is greater than the beginning of the month (subscription has not been cancelled) for Segment 87, then the subscription is active for Segment 87.
  	CASE WHEN (subscription_start < first_day)
		AND (subscription_end > first_day OR subscription_end IS NULL)
  	AND (segment = 30)
  	THEN 1
  	ELSE 0
 		END AS 'is_active_30', 
--Statement above states that IF value of subscription date is less than the beginning of the month (subscription started before the given month) and subscription end date value is greater than the beginning of the month (subscription has not been cancelled) for Segment 30, then the subscription is active for Segment 30.  	
  	CASE WHEN (subscription_end BETWEEN first_day AND last_day)
  	AND (segment = 30)
  	THEN 1
  	ELSE 0
  	END AS 'is_canceled_30',
--Statement above states that if the subscription final date for segment 30 falls between the beginning and the end of the month, then the subscription is cancelled for that segment. 
  	CASE WHEN (subscription_end BETWEEN first_day AND last_day) 
  	AND (segment = 87)  
  	THEN 1
  	ELSE 0
  	END AS 'is_canceled_87'
 --Statement above states that if the subscription final date for segment 87 falls between the beginning and the end of the month, then the subscription is cancelled for that segment. 
  FROM cross_join),
--Create status_aggregate table below:
status_aggregate AS (
SELECT month, SUM(is_active_30) AS 'sum_active_30', SUM(is_active_87) AS 'sum_active_87', SUM(is_canceled_87) AS 'sum_canceled_87', SUM(is_canceled_30) AS 'sum_canceled_30'
FROM status
GROUP BY 1)
--The statement above creates a temporary table summarizing the active and cancelled subscriptions for Segments 30 and 87.
SELECT month, ROUND(1.0 * sum_canceled_87 / sum_active_87, 2) AS 'churn_rate_87', ROUND(1.0 * sum_canceled_30 / sum_active_30, 2) AS 'churn_rate_30'
FROM status_aggregate; 
--Calculate the churn rate above by taking the total canceled subscriptions for that month divided by the total active subscription. 


