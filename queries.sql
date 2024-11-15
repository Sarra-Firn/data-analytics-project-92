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

with tab as (
select CONCAT(e.first_name, ' ', e.last_name) as seller, 
		FLOOR(AVG(p.price*s.quantity)) as average_income
		FROM employees as e
left join sales as s
on  e.employee_id=s.sales_person_id
inner join products as p
on s.product_id = p.product_id
group by CONCAT(e.first_name, ' ', e.last_name))
select tab.seller,
	 	tab.average_income
from tab
group by tab.seller, tab.average_income
having tab.average_income < (select AVG(p.price*s.quantity) as avg
							FROM products as p
							left join sales as s
							on p.product_id=s.product_id)
order by tab.average_income;


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
order by seller, extract ('isodow' from s.sale_date);


количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+
select CASE
  WHEN age BETWEEN 16 AND 25 THEN '16-25'
  WHEN age BETWEEN 26 AND 40 THEN '26-40'
  WHEN age >= 40 THEN '40+'
END AS age_category, COUNT (*) AS age_count
FROM customers as c
group by 1
order by 1;


Данные по количеству уникальных покупателей и выручке, которую они принесли
select CONCAT(c.first_name, '',c.last_name) as customer,
min(s.sale_date) as sale_date,
CONCAT(e.first_name, '', e.last_name) as seller
FROM customers as c
left join sales as s
on c.customer_id=s.customer_id
left join products as p
on p.product_id=s.product_id
left join employees as e
on e.employee_id=s.sales_person_id
where p.price =0
group by 1, 3, c.customer_id
order by c.customer_id;


отчет о покупателях, первая покупка которых была в ходе проведения акций (акционные товары отпускали со стоимостью равной 0)
select CONCAT(c.first_name, '',c.last_name) as customer,
min(s.sale_date) as sale_date,
CONCAT(e.first_name, '', e.last_name) as seller
FROM customers as c
left join sales as s
on c.customer_id=s.customer_id
left join products as p
on p.product_id=s.product_id
left join employees as e
on e.employee_id=s.sales_person_id
where p.price =0
group by 1, 3, c.customer_id
order by c.customer_id;