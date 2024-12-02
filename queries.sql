/*запрос, который считает общее количество покупателей из таблицы customers*/
select COUNT(customer_id) as customers_count
from customers;

/*Отчёт с продавцами у которых наибольшая выручка*/
select CONCAT(first_name, ' ', last_name) as seller, 
	COUNT(s.sales_id) as operations,
	FLOOR(SUM(p.price*s.quantity)) as income
FROM sales as s
left join employees as e
on  s.sales_person_id=e.employee_id
left join products as p
on s.product_id = p.product_id 
group by CONCAT(first_name, ' ', last_name)
order by income desc
limit 10;


/*Отчёт с продавцами, чья выручка ниже средней выручки всех продавцов:*/
select CONCAT(e.first_name, ' ', e.last_name) as seller, 
	FLOOR(AVG(p.price*s.quantity)) as average_income
	FROM employees as e
left join sales as s
on  e.employee_id=s.sales_person_id
inner join products as p
on s.product_id = p.product_id
group by CONCAT(e.first_name, ' ', e.last_name)
having FLOOR(AVG(p.price*s.quantity)) < (select AVG(p.price*s.quantity) as avg
						FROM products as p
						left join sales as s
						on p.product_id=s.product_id)
order by average_income;


/*Отчёт с данными по выручке по каждому продавцу и дню недели:*/
select CONCAT(e.first_name, ' ', e.last_name) as seller,
	to_char(s.sale_date, 'day') as day_of_week,
	FLOOR(SUM(p.price*s.quantity)) as average_income
	FROM employees as e
left join sales as s
on  e.employee_id=s.sales_person_id
inner join products as p
on s.product_id = p.product_id
group by seller, extract ('isodow' from s.sale_date), to_char(s.sale_date, 'day')
order by extract ('isodow' from s.sale_date), seller;


/*количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+*/
select CASE
  WHEN age BETWEEN 16 AND 25 THEN '16-25'
  WHEN age BETWEEN 26 AND 40 THEN '26-40'
  WHEN age >= 40 THEN '40+'
END AS age_category, COUNT (*) AS age_count
FROM customers as c
group by 1
order by 1;


/*Данные по количеству уникальных покупателей и выручке, которую они принесли*/
select to_char(s.sale_date, 'yyyy-MM') as date,
	COUNT (distinct c.customer_id) as total_customers,
	SUM(p.price*s.quantity) as income
FROM sales as s
left join customers as c
on s.customer_id=c.customer_id
left join products as p
on s.product_id=p.product_id
group by 1
order by 1;


/*отчет о покупателях, первая покупка которых была в ходе проведения акций (акционные товары отпускали со стоимостью равной 0)*/
WITH tab AS (
    SELECT 
        CONCAT(c.first_name, ' ', c.last_name) AS customer,
        MIN(s.sale_date) AS sale_date,
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        ROW_NUMBER() OVER (PARTITION BY c.customer_id ORDER BY MIN(s.sale_date)) AS rn
    FROM customers AS c
    LEFT JOIN sales AS s ON c.customer_id = s.customer_id
    LEFT JOIN products AS p ON p.product_id = s.product_id
    LEFT JOIN employees AS e ON e.employee_id = s.sales_person_id
    WHERE p.price = 0 
    GROUP BY c.customer_id, c.first_name, c.last_name, e.first_name, e.last_name
)
SELECT 
    customer,
    sale_date,
    seller
FROM tab
WHERE rn = 1
ORDER BY sale_date;