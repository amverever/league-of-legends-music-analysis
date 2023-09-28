USE lolmusic;

SELECT 
	count(track_id) as counts,
    sum(spotify_stream) as total_spotify,
    round(avg(spotify_stream)) as avg_spotify,
    sum(youtube_views) as total_youtube,
    round(avg(youtube_views)) as avg_youtube
    FROM music_stream_stat;
    
## Stream Stats per Category
SELECT 
    mi.category, COUNT(mi.track_id) AS counts, sum(ms.spotify_stream) as total_spotify_stream, sum(ms.youtube_views) as total_youtube_views
FROM
    music_info as mi
JOIN music_stream_stat as ms ON mi.track_id = ms.track_id
GROUP BY category
ORDER BY counts DESC;

## Stream Stats per Release Year
SELECT 
    mi.release_year, COUNT(mi.track_id) AS counts, sum(ms.spotify_stream) as total_spotify_stream, sum(ms.youtube_views) as total_youtube_views
FROM
    music_info as mi
JOIN music_stream_stat as ms ON mi.track_id = ms.track_id
GROUP BY mi.release_year
ORDER BY counts DESC;

# Music for Release
SELECT
	release_year,
	COUNT(track_id) as counts
FROM music_info
WHERE category = 'Original Game' AND release_for <> 'Original Game Soundtrack'
GROUP BY release_year;

# Release with Musics per Year
SELECT 
	B.year, COUNT(B.update_id) as counts 
FROM (
	SELECT 
		*, CONCAT(release_for, ' ', release_for_detail) AS concat_1 
    FROM 
		music_info 
	WHERE 
		category = 'Original Game') as A 
JOIN (
	SELECT
		*, CONCAT(update_category, ' ', update_detail) as concat_2 
	FROM 
		game_advanced) as B 
ON A.concat_1 = B.concat_2 
GROUP BY B.year;

## Release with Music per category
SELECT 
    B.update_category, COUNT(A.track_id) as counts
FROM (
    SELECT 
        *, CONCAT(release_for, ' ', release_for_detail) AS concat_1
    FROM
        music_info
    WHERE
        category = 'Original Game') as A
JOIN (
	SELECT 
		*, CONCAT(update_category, ' ', update_detail) as concat_2 
    FROM 
		game_advanced) as B
ON A.concat_1 = B.concat_2
GROUP BY B.update_category;

## World Championship Theme songs
SELECT count(mi.track_id) as counts, sum(ms.spotify_stream) as total_spotify_stream, sum(ms.youtube_views) as total_youtube_views, ee.event_name, ee.year
FROM music_stream_stat as ms
JOIN music_info as mi
ON ms.track_id = mi.track_id
JOIN esports_events as ee
ON mi.release_for_detail = ee.event_name
WHERE ee.event_name LIKE "%World Championship"
GROUP BY ee.event_name, ee.year;

SELECT mi.track_title
FROM music_stream_stat as ms
JOIN music_info as mi
ON ms.track_id = mi.track_id
JOIN esports_events as ee
ON mi.release_for_detail = ee.event_name
WHERE ee.event_name LIKE "%World Championship";


## Other Event Theme Songs
SELECT count(mi.track_id) as counts, sum(ms.spotify_stream) as total_spotify_stream, sum(ms.youtube_views) as total_youtube_views, ee.category, ee.event_name, ee.year
FROM music_stream_stat as ms
JOIN music_info as mi
ON ms.track_id = mi.track_id
JOIN esports_events as ee
ON mi.release_for_detail = ee.event_name
WHERE ee.event_name NOT LIKE "%World Championship"
GROUP BY ee.category, ee.event_name, ee.year;


# IP Variation Streaming Performance
SELECT mi.category, mi.release_year, sum(ms.spotify_stream) as total
FROM music_stream_stat as ms
JOIN music_info as mi
ON ms.track_id = mi.track_id
GROUP BY mi.category, mi.release_year
ORDER BY mi.release_year;
