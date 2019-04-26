#Heloisa Walsh - SQL Homework Assignment - Sakila Database

use sakila;

-- 1a. Display the first and last names of all actors from the table actor.

select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

select upper (concat(first_name," ", last_name))
as "Actor Name"
from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?

select actor_id, first_name, last_name
from actor
where first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:

select * from actor where last_name like "%gen%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

select last_name, first_name from actor where last_name like "%li%";

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

select * from country where country in ("Afghanistan", "Bangladesh", "China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

alter table actor
add Description blob;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.

alter table actor
drop column Description; 

-- 4a. List the last names of actors, as well as how many actors have that last name.

select last_name, count(last_name) as "Last Name Count"
from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors

select last_name, count(last_name) as "Last Name Count"
from actor
group by last_name 
having count(last_name) >= 2; 

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
-- Write a query to fix the record.

update actor
set first_name = "HARPO"
where actor_id = 172;

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
-- It turns out that GROUCHO was the correct name after all! In a single query, 
-- if the first name of the actor is currently HARPO, change it to GROUCHO.

update actor set first_name = "GROUCHO" where actor_id = 172;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html 

show create table address;
CREATE TABLE address (
	address_id smallint(5) unsigned NOT NULL AUTO_INCREMENT,
	address varchar(50) NOT NULL,
	address2 varchar(50) DEFAULT NULL,
	district varchar(20) NOT NULL,
	city_id smallint(5) unsigned NOT NULL,
	postal_code varchar(10) DEFAULT NULL,
	phone varchar(20) NOT NULL,
	location geometry NOT NULL,
	last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (address_id),
	KEY idx_fk_city_id (city_id),
	SPATIAL KEY idx_location (location),
	CONSTRAINT fk_address_city FOREIGN KEY (city_id) REFERENCES city (city_id) ON UPDATE CASCADE
	) 
    ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

-- 6a. Use JOIN to display the first and last names, as well as the address, 
-- of each staff member. Use the tables staff and address:

select * from staff;
select * from address;
select first_name, last_name, address from staff as s
inner join address as a
on s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.

select concat(s.first_name, " ", s.last_name), sum(p.amount) as "Total Amount" 
from payment as p
inner join staff as s
on p.staff_id = s.staff_id
where date(p.payment_date) between "2005-08-01" and "2005-08-31"
group by p.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner join.

select f.title as "Film Title", count(fa.actor_id) as "Total Actors in Film"
from film as f
inner join film_actor as fa
on f.film_id = fa.film_id
group by f.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

select count(f.film_id) as "Inventory Amount", f.title as "Movie Title"
from film as f
inner join inventory as i
on f.film_id = i.film_id
where f.title = "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:

select c.last_name as "Last Name", c.first_name as "First Name", sum(p.amount) as "Total Paid"
from payment as p
inner join customer as c
on c.customer_id = p.customer_id
group by p.customer_id
order by c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

select title, l.language_id
from film, language l
where (title like "K%"
or title like "Q%")
and l.language_id = 
	(
    select language_id
	from language
	where name = "english"
    );
    
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

select a.first_name, a.last_name
from actor a, film_actor fa
where (a.actor_id = fa.actor_id)
and film_id = 
	(
    select film_id 
    from film 
    where title = "Alone Trip"
    );

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names 
-- and email addresses of all Canadian customers. Use joins to retrieve this information.  
  
select c.first_name, c.last_name, c.email, cou.country
from customer c
inner join address a on c.address_id = a.address_id
inner join city ci on a.city_id = ci.city_id
inner join country cou on ci.country_id = cou.country_id
and cou.country_id = 
	(
    select cou.country_id
    from country cou
    where cou.country = "Canada"
    );

-- 7d. Sales have been lagging among young families, and you wish to target all 
-- family movies for a promotion. Identify all movies categorized as family films.

select f.title as "Film Tile", cat.name as "Film Category"
from film f
inner join film_category fc on f.film_id = fc.film_id
inner join category cat on fc.category_id = cat.category_id
and cat.name =
	(
	select cat.name
	from category cat
	where cat.name = "Family"
	);

-- 7e. Display the most frequently rented movies in descending order.

select f.title as "Film Title", count(i.film_id) as "Times Rented"
from film f
inner join inventory i on f.film_id = i.film_id
group by i.film_id
order by count(i.film_id) desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
#store/store_id, Inventory/store_id, count(inventory_id), film_id, Film/film_id, sum(rental_rate)

select s.store_id, (sum(f.rental_rate) * count(i.film_id)) as "Revenue from Rentals"
from store as s
inner join inventory as i on s.store_id = i.store_id
inner join film as f on i.film_id = f.film_id
group by s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

select s.store_id as "Store ID", ci.city as "City", cou.country as "Country"
from store s, address a, city ci, country cou
where s.address_id = a.address_id
and a.city_id = ci.city_id
and ci.country_id = cou.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

select cat.name as "Film Genres", (sum(p.amount) * count(i.film_id)) as "Gross Revenue"
from category as cat
join film_category as fc on cat.category_id = fc.category_id
join inventory as i on fc.film_id = i.film_id
join rental as r on i.inventory_id = r.inventory_id
join payment as p on r.rental_id = p.rental_id
group by cat.name
order by "Gross Revenue" desc limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of 
-- viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.

create view Top_Genre_Revenue as
	select cat.name as "Film Genres", (sum(p.amount) * count(i.film_id)) as "Gross Revenue"
	from category as cat
	join film_category as fc on cat.category_id = fc.category_id
	join inventory as i on fc.film_id = i.film_id
	join rental as r on i.inventory_id = r.inventory_id
	join payment as p on r.rental_id = p.rental_id
	group by cat.name
	order by "Gross Revenue" desc limit 5;

-- 8b. How would you display the view that you created in 8a?

select * from Top_Genre_Revenue;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

drop view Top_Genre_Revenue;
