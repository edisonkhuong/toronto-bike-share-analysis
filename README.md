# 🚲 Toronto Bike Share 2018 — Ridership Analysis

A full end-to-end data analysis project exploring ridership patterns in Toronto's Bike Share program using Python, PostgreSQL, and Tableau.

---

## Table of Contents
- [Project Overview](#project-overview)
- [Dataset](#dataset)
- [Tools Used](#tools-used)
- [Data Cleaning (Python)](#data-cleaning-python)
- [Data Analysis (SQL)](#data-analysis-sql)
- [Visualizations (Tableau)](#visualizations-tableau)
- [Key Findings](#key-findings)
- [Recommendations](#recommendations)
- [Project Structure](#project-structure)

---

## Project Overview

This project analyzes over 1.9 million bike share trips taken in Toronto in 2018. The goal was to uncover ridership patterns across user types, time of day, day of week, and station popularity — and to draw actionable conclusions for the bike share operator.

**Hypotheses tested:**
1. Members take shorter trips than Casual riders
2. Trip volume is higher in summer months than winter
3. Certain stations are significantly busier than others
4. Casual riders use the system more on weekends; Members more on weekdays
5. Rush hour peaks are visible on weekdays but not weekends

---

## Dataset

- **Source:** [Toronto Bike Share Open Data](https://open.toronto.ca/dataset/bike-share-toronto-ridership-data/)
- **Scope:** 2018 (Q1–Q4), provided as 4 separate CSV files
- **Raw rows:** ~1.9 million trips
- **Columns:** `trip_id`, `trip_start_time`, `trip_stop_time`, `trip_duration_seconds`, `from_station_id`, `from_station_name`, `to_station_id`, `to_station_name`, `user_type`

---

## Tools Used

| Tool | Purpose |
|---|---|
| Python (pandas) | Data loading, cleaning, transformation |
| PostgreSQL + pgAdmin | Data storage and SQL analysis |
| Tableau Public | Interactive visualizations and dashboard |

---

## Data Cleaning (Python)

The raw data required several cleaning steps before analysis:

**1. Loading multiple files**

The 2018 data came in 4 quarterly CSV files with inconsistent naming conventions. All files were loaded and concatenated into a single dataframe:

```python
import pandas as pd

all_files = [
    'Bike Share Toronto Ridership_Q1 2018.csv',
    'Bike Share Toronto Ridership_Q2 2018.csv',
    'Bike Share Toronto Ridership_Q3 2018.csv',
    'Bike Share Toronto Ridership_Q4 2018.csv',
]

df = pd.concat([pd.read_csv(f) for f in all_files], ignore_index=True)
```

**2. Datetime parsing**

The `trip_start_time` and `trip_stop_time` columns were stored as strings and required parsing:

```python
df['trip_start_time'] = pd.to_datetime(df['trip_start_time'])
df['trip_stop_time'] = pd.to_datetime(df['trip_stop_time'])
```

**3. Standardizing user types**

The `user_type` column contained two inconsistent labels per category (`Annual Member` / `Member` and `Casual Member` / `Casual`). These were standardized:

```python
df['user_type'] = df['user_type'].replace({
    'Annual Member': 'Member',
    'Casual Member': 'Casual'
})
```

**4. Extracting time features**

New columns were derived from `trip_start_time` to enable time-based analysis:

```python
df['year'] = df['trip_start_time'].dt.year
df['month'] = df['trip_start_time'].dt.month
df['day_of_week'] = df['trip_start_time'].dt.day_name()
df['hour'] = df['trip_start_time'].dt.hour
```

**5. Filtering invalid durations**

Trips shorter than 1 minute (likely docking errors) and longer than 24 hours (likely unreturned bikes) were removed:

```python
df = df[(df['trip_duration_seconds'] >= 60) & (df['trip_duration_seconds'] <= 86400)]
```

**Result:** 1,922,955 clean rows exported to `toronto_bikes_clean.csv`

---

## Data Analysis (SQL)

The cleaned CSV was imported into PostgreSQL for analysis. Key queries:

**Average trip duration by user type**
```sql
SELECT 
    user_type,
    ROUND(AVG(trip_duration_seconds) / 60.0, 2) AS avg_duration_minutes,
    COUNT(*) AS total_trips
FROM bike_trips
GROUP BY user_type;
```

**Total trips by month**
```sql
SELECT 
    month,
    COUNT(*) AS total_trips
FROM bike_trips
GROUP BY month
ORDER BY month;
```

**Top 10 busiest departure stations**
```sql
SELECT 
    from_station_name,
    COUNT(*) AS departures
FROM bike_trips
GROUP BY from_station_name
ORDER BY departures DESC
LIMIT 10;
```

**Trips by user type and day of week**
```sql
SELECT 
    user_type,
    day_of_week,
    COUNT(*) AS total_trips
FROM bike_trips
GROUP BY user_type, day_of_week
ORDER BY user_type, total_trips DESC;
```

**Peak hours by user type**
```sql
SELECT
    hour,
    user_type,
    COUNT(*) AS total_trips
FROM bike_trips
WHERE user_type = 'Member'
GROUP BY hour, user_type
ORDER BY total_trips DESC;
```

---

## Visualizations (Tableau)

An interactive dashboard was built in Tableau Public containing 5 views:

1. **Average Trip Duration by User Type** — bar chart comparing Member vs Casual average ride length
2. **Total Trips by Month** — line chart showing seasonal demand across 2018
3. **Top 10 Busiest Departure Stations** — horizontal bar chart ranked by departure count
4. **Trip Frequency by Day and Hour** — heatmap showing rush hour and weekend patterns
5. **Trips by Day of Week: Member vs Casual** — side-by-side bar chart comparing user behaviour by day

> 📊 [View the Tableau Dashboard](https://public.tableau.com/views/TorontoBikeShare2018-RidershipAnalysis/Dashboard1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link) ← *(replace with your Tableau Public link)*

---

## Key Findings

**1. Casual riders take nearly 3x longer trips than Members**
- Average trip duration: Casual = 33.87 min, Member = 12.08 min
- Members use the system for short, purposeful trips (commuting); Casuals for longer leisure rides
- ✅ Hypothesis confirmed

**2. Ridership is heavily seasonal**
- Trip volume peaks in July–August (~290K trips/month) and drops sharply in winter (January ~45K)
- Demand in peak summer is roughly 6x higher than in winter
- ✅ Hypothesis confirmed

**3. A small number of stations drive a disproportionate share of trips**
- York St / Queens Quay W and Bay St / Queens Quay W are by far the busiest departure stations
- The top 10 stations are concentrated in the downtown core near the waterfront
- ✅ Hypothesis confirmed

**4. Members commute; Casuals explore on weekends**
- Members show consistently high usage Monday–Friday with a notable drop on weekends
- Casual ridership on Saturday and Sunday is proportionally much higher relative to their weekday usage
- ✅ Hypothesis confirmed

**5. Rush hour peaks are a Member-driven phenomenon**
- The heatmap clearly shows 8am and 5–6pm spikes on weekdays, absent on weekends
- This pattern is driven almost entirely by Members, consistent with commuter behaviour
- ✅ Hypothesis confirmed

---

## Recommendations

Based on the analysis, the following recommendations are made for the Toronto Bike Share operator:

1. **Increase bike availability at waterfront stations** — York St / Queens Quay W and Bay St / Queens Quay W are consistently the highest-demand departure points and should be prioritized for restocking
2. **Adjust fleet size seasonally** — with 6x more trips in summer than winter, operational resources (maintenance, redistribution staff) should scale accordingly
3. **Target casual riders for membership conversion** — casual riders take longer trips and ride more on weekends, suggesting they are engaged users who might be converted to annual members with the right incentive
4. **Ensure capacity at commuter stations during rush hour** — the 8am and 5–6pm weekday spikes require reliable bike availability at stations near office districts

---

## Project Structure

```
project_1/
│
├── toronto_bikes_clean.csv       ← cleaned data output from Python
├── Toronto_Bikes.ipynb           ← Python cleaning notebook
├── queries.sql                   ← all SQL analysis queries
└── README.md                     ← this file
```

---

*Analysis by [Your Name] | Tools: Python, PostgreSQL, Tableau Public*
