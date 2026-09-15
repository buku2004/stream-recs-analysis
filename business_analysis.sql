-- 1. Churn rate by subscription plan. Which plan has the highest churn rate?

WITH user_counts AS (
    SELECT
        subscription_plan,
        COUNT(*) AS total_users,
        SUM(CASE WHEN is_active = FALSE THEN 1 ELSE 0 END) AS churned_users
    FROM users
    GROUP BY subscription_plan
)
SELECT
    subscription_plan,
    total_users,
    churned_users,
    ROUND(100.0 * churned_users / total_users, 2) AS churn_rate_pct
FROM user_counts
ORDER BY churn_rate_pct;

-- 2. Monthly Churn Rate for the Year 2023. Is it increasing or decreasing over time?

SELECT 
	DATE_TRUNC('month', subscription_start_date) AS month, 
	COUNT(*) AS total_users,
	SUM(CASE WHEN is_active = FALSE THEN 1 ELSE 0 END) AS churned_users,
	ROUND(
		100 * SUM(CASE WHEN is_active = FALSE THEN 1 ELSE 0 END) / COUNT(*)
		, 2
		) AS churn_rate_pct
FROM users
WHERE EXTRACT(YEAR FROM subscription_start_date) = 2023
GROUP BY month
ORDER BY month;

-- 3. Revenue lost due to churn 

WITH monthly_loss AS (
    SELECT
        DATE_TRUNC('month', subscription_start_date) AS month,
        SUM(monthly_spend) AS monthly_revenue_lost
    FROM users 
    WHERE is_active = FALSE AND
	EXTRACT(YEAR FROM subscription_start_date) = 2023
    GROUP BY month
	ORDER BY month
)
SELECT
    month,
    ROUND(monthly_revenue_lost::numeric, 2) AS monthly_revenue_lost,
    ROUND(SUM(monthly_revenue_lost) OVER (ORDER BY month)::numeric, 2) AS total_revenue_lost
FROM monthly_loss;

-- 4. Average Watch Time: Active vs Churned Users. Grouped by device? 

WITH user_device_stats AS (
    SELECT
        u.is_active,
        u.subscription_plan,
        w.device_type,
        COUNT(DISTINCT u.user_id) AS user_count,
        ROUND(AVG(w.watch_duration_minutes)::numeric, 2) AS avg_watch_time
    FROM users u
    JOIN watch_history w ON u.user_id = w.user_id
    GROUP BY u.is_active, u.subscription_plan, w.device_type
)
SELECT * 
FROM user_device_stats
ORDER BY subscription_plan, device_type, is_active DESC;

-- 5. Average revenue per user (ARPU) by subscription plan. Which plan is the most profitable?

SELECT 
	subscription_plan, 
	COUNT(*) AS total_users, 
	ROUND(SUM(monthly_spend)::numeric, 2) AS revenue_per_month
FROM users
WHERE monthly_spend BETWEEN '1.00' AND '200.00'
GROUP BY subscription_plan
ORDER BY revenue_per_month DESC;

-- 6.  Least watched movies to decide
--    which movies to remove from the platform.

WITH movie_summary AS (
    SELECT
        m.movie_id,
        m.title,
        COUNT(w.session_id) AS views
    FROM movies m
    JOIN watch_history w ON m.movie_id = w.movie_id
    GROUP BY m.movie_id, m.title
)
SELECT
    movie_id,
    title,
    views,
    ROUND(100.0 * views / SUM(views) OVER (), 2) AS pct_of_views
FROM movie_summary
ORDER BY views ASC
LIMIT 10;

-- 7. Average watch time by device type. Which device has the highest engagement?
-- Helpful to know which device to improve the user experience on.

SELECT 
	device_type, 
	COUNT(*) AS sessions,
	ROUND(AVG(watch_duration_minutes)::numeric, 2) AS avg_watch_time
FROM watch_history
GROUP BY device_type
ORDER BY sessions DESC;

-- 8. Cities with top revenue. Which cities are generating the most revenue for the platform?

SELECT
	country,
    city,
    ROUND(SUM(monthly_spend)::numeric, 2)AS revenue
FROM users
GROUP BY country, city
ORDER BY revenue DESC
LIMIT 10;

-- 9. Favourite genre of active users so we can recommend similar content to them.

SELECT 
	m.genre_primary, 
	ROUND(SUM(watch_duration_minutes)::numeric / 60.0, 2) AS watchtime_hrs
FROM users u JOIN watch_history wh
ON u.user_id = wh.user_id
JOIN movies m 
ON wh.movie_id = m.movie_id
WHERE u.is_active = TRUE
GROUP BY m.genre_primary 
ORDER BY watchtime_hrs DESC
LIMIT 7;

-- 10. Performance of different recommendation algorithms. and 
--     is high confidence actually translating into clicks?

WITH algorithm_stats AS (
	SELECT 
		algorithm_version,
		COUNT(*) AS total_recommendations, 
		SUM(CASE WHEN was_clicked = TRUE THEN 1 ELSE 0 END) AS total_clicks, 
		ROUND(AVG(recommendation_score)::numeric, 2) AS avg_recommendation_score,
		ROUND(
            100.0 * SUM(CASE WHEN was_clicked THEN 1 ELSE 0 END) / COUNT(*),
            2
        ) AS ctr_percentage
	FROM recommendations
	GROUP BY algorithm_version	
)

SELECT
	*,
	RANK() OVER(ORDER BY ctr_percentage DESC) AS ctr_rank,
	RANK() OVER(ORDER BY avg_recommendation_score DESC) AS confidence_rank
FROM algorithm_stats
ORDER BY ctr_percentage DESC;

-- 11. Which position in the recommendation list has the highest click-through rate (CTR) and clicks?

SELECT
    position_in_list,
    COUNT(*) AS recommendations,
    SUM(CASE WHEN was_clicked THEN 1 ELSE 0 END) AS clicks,
    ROUND(
        100.0 * SUM(CASE WHEN was_clicked THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS ctr_percentage,
    RANK() OVER(
        ORDER BY
        100.0 * SUM(CASE WHEN was_clicked THEN 1 ELSE 0 END) / COUNT(*) DESC
    ) AS position_rank
FROM recommendations
GROUP BY position_in_list
ORDER BY position_rank;

-- 12. Find users who watch more than 3 hours in a single day

WITH user_stats AS (
	SELECT
		u.user_id,
		u.first_name,
		u.last_name,
		EXTRACT(ISODOW FROM watch_date::date) AS day,
		TO_CHAR(watch_date::date, 'Day') AS day_name,
		SUM(watch_duration_minutes) AS daily_watchtime
		FROM watch_history wh JOIN users u
		ON wh.user_id = u.user_id
		GROUP BY u.user_id, first_name, last_name, day, day_name
		ORDER BY daily_watchtime DESC
)
SELECT 
	user_id,
	first_name,
	last_name, 
	day_name,
	daily_watchtime
	FROM user_stats
	WHERE daily_watchtime > 180
	ORDER BY daily_watchtime DESC;

-- 13. lifetime user value (LTV) by subscription plan. Which plan is the most valuable?

SELECT
    user_id,
    subscription_plan,
    monthly_spend,
    AGE(CURRENT_DATE, subscription_start_date) AS membership_duration,
    monthly_spend *
    (
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, subscription_start_date))*12 +
        EXTRACT(MONTH FROM AGE(CURRENT_DATE, subscription_start_date))
    ) AS estimated_ltv
FROM users
ORDER BY estimated_ltv DESC;