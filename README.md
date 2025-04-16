# SQL-Project-2-Spotify-Analysis

## Overview
This project involves analyzing a Spotify dataset with various attributes about tracks, albums, and artists using **PostgreSQL**. It covers an end-to-end process of normalizing a denormalized dataset, performing SQL queries of varying complexity (easy, medium, and advanced), and optimizing query performance. The primary goals of the project are to practice advanced SQL skills and generate valuable insights from the dataset.

```sql
-- create table
DROP TABLE IF EXISTS spotify;
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
```
## Project Steps

### 1. Data Exploration
Before diving into SQL, it’s important to understand the dataset thoroughly. The dataset contains attributes such as:
- `Artist`: The performer of the track.
- `Track`: The name of the song.
- `Album`: The album to which the track belongs.
- `Album_type`: The type of album (e.g., single or album).
- Various metrics such as `danceability`, `energy`, `loudness`, `tempo`, and more.

### 4. Querying the Data
After the data is inserted, various SQL queries can be written to explore and analyze the data. Queries are categorized into **easy**, **medium**, and **advanced** levels to help progressively develop SQL proficiency.

-- 1. Retrieve the names of all tracks that have more than 1 billion streams.
```sql
select *
from spotify
where stream >= 1000000000;
```

-- 2. List all albums along with their respective artists for the above tracks.
```sql
select album, track, artist
from spotify
where stream >= 1000000000;
```

-- 3. Get the total number of comments for liscensed tracks.
```sql
select sum(comments) as total_cmnts
from spotify
where licensed = true;
```

-- 4. Find all tracks that belong to the album type single.
```sql
select *
from spotify
where album_type = 'single';
```

-- 5. Count the total number of tracks by each artist.
```sql
select artist, count(track) as total_tracks
from spotify
group by artist
order by total_tracks;
```

-- 6. Calculate the average danceability of tracks in each album.
```sql
select track, avg(danceability) as avg_danceability
from spotify
group by track
order by avg_danceability desc;
```

-- 7. Find the top 5 tracks with the highest energy values.
```sql
select track, energy
from spotify
order by energy desc
limit 5;
```

-- 8. List all official tracks along with their views and likes.
```sql
select track, sum(views) as views, sum(likes) as likes
from spotify
where official_video = true
group by track
order by views desc;
```

-- 9. For each album, calculate the total views of all associated tracks.
```sql
select album, track, sum(views) as total_views
from spotify
group by album, track
order by total_views desc;
```

-- 10. Retrieve the track names that have been streamed on Spotify more than YouTube.
```sql
select * from
(
select track,
	   coalesce(sum(case when most_played_on = 'Youtube' then stream end)) as streamed_on_youtube,
	   coalesce(sum(case when most_played_on = 'Spotify' then stream end)) as streamed_on_spotify
from spotify
group by track
) as t1
where streamed_on_spotify > streamed_on_youtube and streamed_on_youtube != 0;
```

-- 11. Find the top 3 most-viewed tracks for each artist using window functions.
```sql
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
```

-- 12. Write a query to find tracks where the liveness score is above the average.
```sql
select track
from spotify
where liveness > (select avg(liveness) from spotify)
group by track;
```

-- 13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
```sql
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
```

-- 14. Find tracks where the energy-to-liveness ratio is greater than 1.2
```sql
select track
from spotify
where (energy / liveness) > 1.2;
```

-- 15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
```sql
select album,
       track,
	   views,
	   sum(likes) over (partition by album order by views desc) as cumm_likes
from spotify
```

