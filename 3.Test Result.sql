           

--Table of distribution of test participants by test group, geographic region and device type.            

        WITH profiles AS (-- Let's create a user profile

                SELECT DISTINCT user_id,
                       MIN(install_date) OVER (PARTITION BY user_id) AS install_date,
                       MAX(registration_flag) OVER (PARTITION BY user_id) AS registration_flag,
                       FIRST_VALUE(region) OVER (PARTITION BY user_id ORDER BY session_start_ts) AS first_region,
                       FIRST_VALUE(device) OVER (PARTITION BY user_id ORDER BY session_start_ts) AS first_device,
                       FIRST_VALUE(test_name) OVER (PARTITION BY user_id ORDER BY session_start_ts) AS test_name,
                       FIRST_VALUE(test_group) OVER (PARTITION BY user_id ORDER BY session_start_ts) AS test_group
                FROM sessions_project_test
                WHERE install_date BETWEEN '2020-10-14' AND '2020-10-20'

            )
            SELECT
            test_group,first_region, first_device, test_name, COUNT(test_group) AS new_dau
            FROM profiles
            GROUP BY test_group, first_region, first_device, test_name


			          

--Test results table           

          WITH profiles AS (-- Let's create a user profile

                SELECT DISTINCT user_id,
                       MIN(install_date) OVER (PARTITION BY user_id) AS install_date,
                       MAX(registration_flag) OVER (PARTITION BY user_id) AS registration_flag,
                       FIRST_VALUE(region) OVER (PARTITION BY user_id ORDER BY session_start_ts) AS first_region,
                       FIRST_VALUE(device) OVER (PARTITION BY user_id ORDER BY session_start_ts) AS first_device,
                       FIRST_VALUE(test_name) OVER (PARTITION BY user_id ORDER BY session_start_ts) AS test_name,
                       FIRST_VALUE(test_group) OVER (PARTITION BY user_id ORDER BY session_start_ts) AS test_group
                FROM sessions_project_test
                WHERE install_date BETWEEN '2020-10-14' AND '2020-10-20'

            ),

            -- Get data about purchases

            orders AS (

                  select 
                    user_id,
                    count(*) as transactions,
                    sum(price) as revenue
                  from purchases_project_test
                  where category = 'computer_equipments'
                  group by user_id

            )

            -- Let's combine everything into a single data set

            SELECT p.user_id,
                   p.install_date,
                   p.test_group,
                   o.transactions,
                   o.revenue
            FROM profiles p
            LEFT JOIN orders o ON o.user_id = p.user_id