CREATE TABLE bike_trips (
    trip_id              INT,
    trip_duration_seconds INT,
    from_station_id      INT,
    trip_start_time      TIMESTAMP,
    from_station_name    VARCHAR(100),
    trip_stop_time       TIMESTAMP,
    to_station_id        INT,
    to_station_name      VARCHAR(100),
    user_type            VARCHAR(20),
    year                 INT,
    month                INT,
    day_of_week          VARCHAR(10),
    hour                 INT
);

SELECT COUNT(*) FROM bike_trips;
-- Should return 1922955
SELECT * FROM bike_trips LIMIT 5;

-- 1. Do Members take shorter trips than Casual riders?
SELECT
	user_type,
	ROUND(AVG(trip_duration_seconds)/60.0,2) as avg_duration_minutes,
	COUNT(*) as total_trips
FROM bike_trips
GROUP BY user_type;

-- 2. Which months have the most trips? (seasonal demand)
SELECT 
	month,
	COUNT(*) AS total_trips
FROM bike_trips
GROUP BY month
ORDER BY month;

-- 3. What are the busiest stations?
SELECT
	from_station_name,
	COUNT(*) AS departures
FROM bike_trips
GROUP BY from_station_name
ORDER BY departures DESC
LIMIT 10;

-- 4. Do Casual riders use it more on weekends vs Members on weekdays?

SELECT
	user_type,
	day_of_week,
	COUNT(*) as total_trips
FROM bike_trips
GROUP BY user_type, day_of_week
ORDER BY user_type, total_trips DESC;

-- 5. What are the peak hours for members?

SELECT
    hour,
    user_type,
    COUNT(*) AS total_trips
FROM bike_trips
WHERE user_type = 'Member'
GROUP BY hour, user_type
ORDER BY total_trips DESC;


-- 6. What are the peak hours for casual?

SELECT
    hour,
    user_type,
    COUNT(*) AS total_trips
FROM bike_trips
WHERE user_type = 'Casual'
GROUP BY hour, user_type
ORDER BY total_trips DESC;




