Q1: Who is the senior most employee based on job title?
select * from employee
order by levels desc
limit 1;

Q2: Which countries have the most invoices?
SELECT count (*) as c, billing_country from invoice
group by billing_country
order by c DESC

Q3: What are the top 3 values of invoices?
select total from invoice
order by total DESC
limit 3;

Q4: Which city has the best customers?
select SUM(total) as invoice_total, billing_city
from invoice
group by billing_city
order by invoice_total DESC

Q5: Who is the best customer?
SELECT customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1

Q6: Return email, first and last name and genre of all rock music listeners in alphabetical order by email
select distinct email, first_name, last_name from customer
join invoice on customer.customer_id = invoice.invoice_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
where track_id in(
		SELECT track_id from track
		join genre on track.genre_id = genre.genre_id
		WHERE genre.name LIKE 'Rock')
ORDER BY email;

Q7: Return the artist name and total track count of the top 10 rock bands.
select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
GROUP BY artist.artist_id
order by number_of_songs desc
limit 10;

Q8: Return all the track names that have a song length longer than the average song length. Return the name and milliseconds for each track.
SELECT name, milliseconds from track
where milliseconds > (
		Select avg(milliseconds) as avg_track_length
		from track)
order by milliseconds desc;

Q9: How much money was spent on artists by customers? Return customer name, artist name and total spent.
WITH best_selling_artist AS (
    SELECT artist.artist_id AS artist_id, artist.name AS artist_name,
    SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
    FROM invoice_line
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN album ON album.album_id = track.album_id
    JOIN artist ON artist.artist_id = album.artist_id
    GROUP BY 1
    ORDER BY 3 DESC
    LIMIT 1
)

SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name,
SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice AS i
JOIN customer AS c ON c.customer_id = i.customer_id
JOIN invoice_line AS il ON il.invoice_id = i.invoice_id
JOIN track AS t ON t.track_id = il.track_id
JOIN album AS alb ON alb.album_id = t.album_id
JOIN best_selling_artist AS bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1, 2, 3, 4
ORDER BY 5 DESC;

Q10: Find the most popular music genre for each country (highest amount of purchase)
WITH popular_genre AS(
	SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo
	FROM invoice_line
	JOIN invoice on invoice.invoice_id = invoice_line.invoice_id
	JOIN customer on customer.customer_id = invoice.customer_id
	JOIN track on track.track_id = invoice_line.track_id
	JOIN genre on genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
	

)
SELECT * FROM popular_genre WHERE RowNo <= 1

Q11: Find the customer who has spent the most money on music for all countries.
WITH RECURSIVE
	customer_with_country AS (
		SELECT customer.customer_id, first_name,last_name,billing_country,SUM(total) AS total_spending
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3 DESC),
	
	coutry_max_spending AS (
		SELECT billing_country, MAX(total_spending) AS max_spending
		FROM customer_with_country
		GROUP BY billing_country)
		
SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customer_with_country cc
JOIN country_max_spending ms
on cc.billing_country = ms.billing_country
ORDER BY 1;