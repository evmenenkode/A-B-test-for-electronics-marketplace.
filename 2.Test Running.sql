--Table of distribution of test participants by days of recruitment, groups, devices and geographic regions.      

            
         WITH profiles AS (   -- Let's create a user profile

                SELECT
                           user_id,
                           install_date,
                           registration_flag,
                           first_region,
                           first_device,
                           test_name,
                           test_group          
                DISTINCT user_id,
                install_date,
                registration_flag,
                FIRST_VALUE(region) OVER(PARTITION BY user_id ORDER BY session_start_ts) as first_region,
                FIRST_VALUE(device) OVER(PARTITION BY user_id ORDER BY session_start_ts) as first_device,
                test_name,
                test_group
                FROM sessions_project_test_part
                WHERE install_date = '2020-10-14'

            )
            SELECT install_date,
                   first_region,
                   first_device,
                   test_name,
                   test_group,
                   COUNT(DISTINCT user_id) AS new_dau
            FROM profiles
            GROUP BY install_date, first_region, first_device, test_name, test_group



--Users included in more than one test group
            

         WITH profiles AS (  -- Let's create a user profile

                SELECT DISTINCT user_id,
                       MIN(install_date) OVER (PARTITION BY user_id) AS install_date,
                       MAX(registration_flag) OVER (PARTITION BY user_id) AS registration_flag,
                       FIRST_VALUE(region) OVER (PARTITION BY user_id ORDER BY session_start_ts) AS first_region,
                       FIRST_VALUE(device) OVER (PARTITION BY user_id ORDER BY session_start_ts) AS first_device,
                       FIRST_VALUE(test_name) OVER (PARTITION BY user_id ORDER BY session_start_ts) AS test_name,
                       test_group
                FROM sessions_project_test_part
                WHERE install_date BETWEEN '2020-10-14' AND '2020-10-14'

            )
            SELECT user_id,
                   COUNT(DISTINCT test_group) AS in_groups
            FROM profiles
            WHERE test_name = 'gaming_laptops_test'
            GROUP BY user_id
            HAVING COUNT(DISTINCT test_group) > 1