
-- Create Database --

# Create Database
DROP DATABASE IF EXISTS lolmusic;
CREATE DATABASE lolmusic;


-- Import Dataframes from MySQL Server --

USE lolmusic;


-- Music General Analysis

SELECT * FROM music_info;

# Number of Tracks - Category Breakdown
SELECT category, count(track_id) as counts
FROM music_info
GROUP BY category
ORDER BY counts desc;

# Number of Tracks - Release Year Breakdown
SELECT release_year, count(track_id) as counts
FROM music_info
GROUP BY release_year
ORDER BY counts desc;

# The Longest Track
SELECT m1.track_id, 
		m1.track_title, 
        m1.category, m1.release_year, 
        m1.release_for, m1.release_for_detail, 
        sec_to_time(m1.duration_second)
FROM music_info as m1
JOIN (
	SELECT (max(duration_second)) as max_duration
FROM music_info) as m2
ON m1.duration_second = m2.max_duration;

# The Shortest Track
SELECT m1.track_id, 
		m1.track_title, 
        m1.category, m1.release_year, 
        m1.release_for, m1.release_for_detail, 
        sec_to_time(m1.duration_second)
FROM music_info as m1
JOIN (
	SELECT (min(duration_second)) as min_duration
FROM music_info) as m2
ON m1.duration_second = m2.min_duration;

# Duration as Hours per Category and Release Year
SELECT category,
		sec_to_time(sum(duration_second)) as sum_duration, 
        sec_to_time(avg(duration_second)) as avg_duration
FROM music_info
GROUP BY category;

# Duration Variance and Standard Deviation
SELECT a.category, sec_to_time(a.variance_sec) as variance_hour, sec_to_time(a.variance_sec) as stddev_hour
FROM 
(SELECT category, VARIANCE(duration_second) as variance_sec, STDDEV(duration_second) as stddev_sec
FROM music_info
GROUP BY category) as a;


-- Album General Analysis --

SELECT * FROM album_info;

# Number of Albums per Album Type and Album Detail
SELECT release_year, album_detail as type, count(album_id) as counts
FROM album_info
GROUP BY release_year, album_detail
ORDER BY release_year, counts desc;

# Number of Albums per Album Type and Category and Release Year
SELECT mi.category, ai.release_year, ai.album_detail as type, count(distinct ai.album_id) as counts
FROM album_info as ai
JOIN music_info as mi ON ai.album_title = mi.album_title
GROUP BY mi.category, ai.release_year, ai.album_detail
ORDER BY ai.release_year;


-- Stream Stat General Analysis --

SELECT * FROM music_stream_stat;

# Add Identifiers
ALTER TABLE music_stream_stat
ADD spotify_bool VARCHAR(3);

UPDATE music_stream_stat
SET spotify_bool = "Yes"
WHERE spotify_stream > 0;

UPDATE music_stream_stat
SET spotify_bool = "No"
WHERE spotify_stream = 0;

ALTER TABLE music_stream_stat
ADD youtube_bool VARCHAR(3);

UPDATE music_stream_stat
SET youtube_bool = "Yes"
WHERE youtube_views > 0;

UPDATE music_stream_stat
SET youtube_bool = "No"
WHERE youtube_views = 0;

# Total Spotify Stream per release_year
SELECT release_year, sum(spotify_stream) as total
FROM music_stream_stat
GROUP BY release_year
ORDER BY release_year;

## Clean duplicated rows: the case of (One song has been released both in an alblum and single, but spotify considers these two as the same.)
select count(distinct spotify_stream)
from music_stream_stat;

select count(distinct track_id)
from music_stream_stat
where spotify_bool = "Yes";

select spotify_stream, count(track_id)
from music_stream_stat
group by spotify_stream
having count(track_id) > 1;

select * from music_info;


-- Clean Duplicated Rows --

select * from music_stream_stat where spotify_stream = 178778799;
update music_stream_stat set spotify_stream = 0 where track_id = 297;
select * from music_stream_stat where spotify_stream = 210319446;
update music_stream_stat set spotify_stream = 0 where track_id = 298;
select * from music_stream_stat where spotify_stream = 759747;
update music_stream_stat set spotify_stream = 0 where track_id = 419;
select * from music_stream_stat where spotify_stream = 3829073;
update music_stream_stat set spotify_stream = 0 where track_id = 420;
select * from music_stream_stat where spotify_stream = 2511368;
update music_stream_stat set spotify_stream = 0 where track_id = 422;
select * from music_stream_stat where spotify_stream = 562361;
update music_stream_stat set spotify_stream = 0 where track_id = 423;
select * from music_stream_stat where spotify_stream = 771095;
update music_stream_stat set spotify_stream = 0 where track_id = 425;


select count(distinct youtube_views)
from music_stream_stat;

select count(distinct track_id)
from music_stream_stat
where youtube_bool = "Yes";

select youtube_views, count(track_id)
from music_stream_stat
group by youtube_views
having count(track_id) > 1;

select * from music_stream_stat where youtube_views = 66598021;
update music_stream_stat set youtube_views = 0 where track_id = 297;
select * from music_stream_stat where youtube_views = 191694343;
update music_stream_stat set youtube_views = 0 where track_id = 298;

# Top Spotify Stream Tracks
SELECT track_id, track_title, release_year, spotify_stream
FROM music_stream_stat
WHERE spotify_bool = "Yes"
ORDER BY spotify_stream DESC
LIMIT 10;

# Total Youtube Views of Music Videos per release_year
SELECT release_year, sum(youtube_views) as total
FROM music_stream_stat
GROUP BY release_year
ORDER BY release_year;

# Total Youtube Views Tracks
SELECT track_id, track_title, youtube_views
FROM music_stream_stat
WHERE youtube_bool = "Yes"
ORDER BY youtube_views DESC
LIMIT 10;

# Difference between Spotify Stream and Youtube Views 
SELECT track_id, track_title, release_year, spotify_stream - youtube_views as difference, abs(spotify_stream - youtube_views) as abs_diff
FROM music_stream_stat
WHERE spotify_bool = "Yes" AND youtube_bool = "Yes"
ORDER BY abs_diff DESC;


-- Game Stats General Analysis --

SELECT * from game_stat;

# Monthly Active User Trends
SELECT year, 
		season, 
        monthly_active_user, 
        monthly_active_user - lag(monthly_active_user, 1) over(ORDER BY year) as diff
FROM game_stat;

# Daily Active User Trends
SELECT year, 
		season, 
        daily_active_user, 
        daily_active_user - lag(daily_active_user, 1) over(ORDER BY year) as diff
FROM game_stat;

select count(*) from album_info;

# Revenue Trends
SELECT year, 
		season, 
        revenue, 
        round(revenue - lag(revenue, 1) over(ORDER BY year), 2) as diff
FROM game_stat;


-- Game Advanced General Analysis --

SELECT * from game_advanced;

# Number of Updates - Category, Year Breakdown and Ranking
SELECT a.update_category, a.year, a.counts, rank() over (partition by update_category order by a.counts desc)
FROM (SELECT update_category, year, count(update_id) as counts
FROM game_advanced
GROUP BY update_category, year
ORDER BY counts desc) as a;


-- Other Games Comparision General Analysis --

SELECT * FROM other_games; 

# Number of Monthly Active Players Ranking / Release Order
SELECT *, 
		RANK() OVER (ORDER BY monthly_active_players DESC) as mau_ranking, 
        RANK() OVER (ORDER BY release_date ASC) as release_order
FROM other_games;

-- Player Demograpic General Analysis --

SELECT * FROM player_demographic;

CREATE TABLE player_dmgp AS (
	SELECT feature_id, 
			category, 
			category_detail, 
			replace (value, "%", "") as value_number
	FROM player_demographic);
    
ALTER TABLE player_dmgp
MODIFY COLUMN value_number INT;

SELECT * FROM player_dmgp;

DROP TABLE IF EXISTS player_demographic;
    
# Gender Breakdown
SELECT category, category_detail, value_number as percentage
FROM player_dmgp
WHERE category = "Gender";

# Age Group Breakdown
SELECT category, category_detail, value_number as percentage
FROM player_dmgp
WHERE category = "Age Group";

# Consumer Pattern Breakdown
SELECT category, category_detail, value_number as percentage
FROM player_dmgp
WHERE category = "Consumer Pattern";

# Country/Breakdown Breakdown
SELECT category, category_detail, value_number as number_of_players
FROM player_dmgp
WHERE category = "Country/Region";


-- Esports Events General Analysis --

SELECT (lag(peak_viewership) over (partition by year) - peak_viewership) FROM esports_events;

# World Championship Trends
SELECT *
FROM esports_events
WHERE category = "World Championship";

# Total peak_viewership Category Breakdown
WITH peak_viewership_table AS (SELECT category, 
						sum(peak_viewership) as sum_of_peak_viewership,
                        max(peak_viewership) as max_of_peak_viewership,
                        min(peak_viewership) as min_of_peak_viewership,
                        avg(peak_viewership) as avg_of_peak_viewership
					FROM esports_events
                    GROUP BY category)
                    
## MAX peak_viewership event
SELECT e.year, e.category, e.event_name, e.peak_viewership
FROM esports_events as e
JOIN peak_viewership_table as p
ON e.category = p.category
WHERE e.peak_viewership = p.max_of_peak_viewership;

# Total avg_viewership Category Breakdown
WITH avg_viewership_table AS (SELECT category, 
						sum(avg_viewership) as sum_of_avg_viewership,
                        max(avg_viewership) as max_of_avg_viewership,
                        min(avg_viewership) as min_of_avg_viewership,
                        avg(avg_viewership) as avg_of_avg_viewership
					FROM esports_events
                    GROUP BY category)
               
## MAX avg_viewership event
SELECT e.year, e.category, e.event_name, e.avg_viewership
FROM esports_events as e
JOIN avg_viewership_table as a
ON e.category = a.category
WHERE e.avg_viewership = a.max_of_avg_viewership;

# Total hours_watched Category Breakdown
WITH hours_watched_table AS (SELECT category, 
						sum(hours_watched) as sum_of_hours_watched,
                        max(hours_watched) as max_of_hours_watched,
                        min(hours_watched) as min_of_hours_watched,
                        avg(hours_watched) as avg_of_hours_watched
					FROM esports_events
                    GROUP BY category)
               
## MAX hour_watched event
SELECT e.year, e.category, e.event_name, e.hours_watched
FROM esports_events as e
JOIN hours_watched_table as h
ON e.category = h.category
WHERE e.hours_watched = h.max_of_hours_watched;
