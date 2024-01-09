--Test preparation: data acquisition

select * from holidays_events_project  /*List of marketing activities*/


WITH
  -- Let's create a user profile
  profiles AS (
    SELECT DISTINCT user_id,
                    MIN(install_date) OVER (PARTITION BY user_id) AS install_date,
                    MAX(registration_flag) OVER (PARTITION BY user_id) AS registration_flag,
                    FIRST_VALUE(region) OVER (PARTITION BY user_id ORDER BY session_start_ts) AS first_region,
                    FIRST_VALUE(device) OVER (PARTITION BY user_id ORDER BY session_start_ts) AS first_device
    FROM sessions_project_history
    WHERE install_date BETWEEN '2020-08-11' AND '2020-09-10'
  ),
  
  -- Get data about purchases
  orders AS (
    SELECT user_id,
           COUNT(*) AS transactions,
           SUM(price) AS revenue
    FROM purchases_project_history
    WHERE category = 'computer_equipments' 
    GROUP BY user_id
  )

-- Let's combine everything into a single data set
SELECT p.user_id,
                   p.install_date,
                   o.transactions,
                   o.revenue
FROM profiles p
LEFT JOIN orders o ON p.user_id = o.user_id;