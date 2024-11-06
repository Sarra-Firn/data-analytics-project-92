Отчёт с продавцами у которых наибольшая выручка

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


Отчёт с продавцами, чья выручка ниже средней выручки всех продавцов:

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


Отчёт с данными по выручке по каждому продавцу и дню недели:
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
