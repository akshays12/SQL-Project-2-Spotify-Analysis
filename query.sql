-- create table
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);


-- EDA

select count(*) from spotify;

select count(distinct artist) from spotify;

select distinct album_type from spotify;

select max(duration_min) as max_duration, min(duration_min) as min_duration from spotify;

-- Removing records where duration is 0
select * from spotify
where duration_min = 0;

delete from spotify
where duration_min = 0;

--
select distinct channel from spotify;

select distinct most_played_on from spotify;

select max(views) as max_views, min(views) as min_views from spotify;

select max(likes) as max_likes, min(likes) as min_likes from spotify;


-- Data Analysis

-- 1. Retrieve the names of all tracks that have more than 1 billion streams.
select *
from spotify
where stream >= 1000000000;

-- 2. List all albums along with their respective artists for the above tracks.
select album, track, artist
from spotify
where stream >= 1000000000;

-- 3. Get the total number of comments for liscensed tracks.
select sum(comments) as total_cmnts
from spotify
where licensed = true;

-- 4. Find all tracks that belong to the album type single.
select *
from spotify
where album_type = 'single';

-- 5. Count the total number of tracks by each artist.
select artist, count(track) as total_tracks
from spotify
group by artist
order by total_tracks;

select * from spotify
-- 6. Calculate the average danceability of tracks in each album.
select track, avg(danceability) as avg_danceability
from spotify
group by track
order by avg_danceability desc;

-- 7. Find the top 5 tracks with the highest energy values.
select track, energy
from spotify
order by energy desc
limit 5;

-- 8. List all official tracks along with their views and likes.
select track, sum(views) as views, sum(likes) as likes
from spotify
where official_video = true
group by track
order by views desc;

-- 9. For each album, calculate the total views of all associated tracks.
select album, track, sum(views) as total_views
from spotify
group by album, track
order by total_views desc;

-- 10. Retrieve the track names that have been streamed on Spotify more than YouTube.
select * from
(
select track,
	   coalesce(sum(case when most_played_on = 'Youtube' then stream end)) as streamed_on_youtube,
	   coalesce(sum(case when most_played_on = 'Spotify' then stream end)) as streamed_on_spotify
from spotify
group by track
) as t1
where streamed_on_spotify > streamed_on_youtube and streamed_on_youtube != 0;

-- 11. Find the top 3 most-viewed tracks for each artist using window functions.
with cte as
(
select artist,
       track,
	   sum(views) as total_views,
	   dense_rank() over (partition by artist order by sum(views) desc) as rnk
from spotify
group by 1, 2
order by 1, 3 desc
)
select artist, track
from cte
where rnk <= 3;

-- 12. Write a query to find tracks where the liveness score is above the average.
select track
from spotify
where liveness > (select avg(liveness) from spotify)
group by track;

-- 13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
with cte as
(
select album, max(energy) as max_energy, min(energy) as min_energy
from spotify
group by album
)
select album, 
       round((max_energy - min_energy)::numeric, 2) as diff
from cte
order by diff desc;

-- 14. Find tracks where the energy-to-liveness ratio is greater than 1.2
select track
from spotify
where (energy / liveness) > 1.2;

-- 15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
select album,
       track,
	   views,
	   sum(likes) over (partition by album order by views desc) as cumm_likes
from spotify

