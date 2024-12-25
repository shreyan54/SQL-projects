use datanetflix;

select * from netflix;

# 1. Count the number of Movies vs TV Shows
SELECT 
	type,
	COUNT(*)
FROM netflix
GROUP BY 1;

#2 Find the most common rating for movies and TV shows
SELECT type,rating
from (
select
	type,
    rating,
	COUNT(*),
	RANK() over(partition by type order by count(*) desc)as ranking
FROM netflix
GROUP BY 1,2
) as t1
where ranking=1;

#3. List all movies released in a specific year (e.g., 2020)
Select  title,release_year  from netflix
where type='Movie'
and release_year=2020;

#4. Find the top 5 countries with the most content on Netflix
select country,count(show_id) as total_content
from netflix
group by 1;

#5. Identify the longest movie
Select title ,duration from netflix
where type='Movie'
and duration=(Select Max(duration) from netflix);

#6. Find content added in the last 5 years
SELECT
    *
FROM
    netflix
WHERE
    date_added >= DATE_SUB(CURRENT_DATE, INTERVAL 5 YEAR);

#7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
Select * from netflix 
where director Like '%Rajiv Chilaka%';

#8. List all TV shows with more than 5 seasons
Select title ,
CAST(SUBSTRING_INDEX(duration, ' ', 1) AS Unsigned) as seasons
from netflix
where type='TV Show'
and duration LIKE '%season%';

#9Count the number of content items in each genre
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(*) as total_content
FROM netflix
GROUP BY 1;

# 10. Find each year and the average numbers of content release by India on netflix. 
#return top 5 year with highest avg content release !

SELECT 
release_year as year,
count(show_id) as total_content,
round(count(show_id)/(SELECT COUNT(show_id) FROM netflix WHERE country = 'India'),2) as avg_release
FROM netflix
WHERE country = 'India' 
group by 1
order by avg_release DESC
LIMIT 5;




#11. List all movies that are documentaries
SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries';


# 12. Find all content without a director
SELECT * FROM netflix
WHERE director IS NULL;

#13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT title FROM netflix
WHERE 
	cast LIKE '%Salman Khan%'
    and  release_year > YEAR(CURRENT_DATE) - 10;
    
#14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
	UNNEST(STRING_TO_ARRAY(cast, ',')) as actor,
	COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

/*
 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/
with new_table as
(Select * ,
case when description like'%kill%' or description like '%violence%' then 'Bad_content'
else 'Good_content'
end category
from netflix 
)
Select category,count(*) as tota_count
from new_table
group by 1;