select distinct c.cust_no, cname, o.order_no from customers c
inner join orders o
on c.cust_no = o.cust_no 
inner join orderlines ol
on o.order_no = ol.order_no 
inner join products p 
on ol.prod_no = p.prod_no where ol.prod_no in(40301, 40303, 40300, 40310, 40306) and upper(cname) like upper('%Outlet%') order by 1;

select c.cust_no, c.cname, o.order_no,p.prod_name,(ol.qty*ol.price) as "Line Sales" from customers c
inner join orders o on c.cust_no = o.cust_no
inner join countries co on c.country_cd = co.country_id
inner join orderlines ol on o.order_no = ol.order_no
inner join products p on p.prod_no = ol.prod_no
where upper(co.country_name) like upper('United Kingdom')
and upper(c.city) like 'L%'
and c.cust_no < 1000 order by o.order_no desc;

select distinct c.cname,nvl(sum(ol.qty),0) from customers c
left outer join orders o on c.cust_no = o.cust_no
left outer join orderlines ol on o.order_no = ol.order_no
where upper(c.cname) like ('A%') or upper(c.cname) like ('C%')
group by c.cname
order by c.cname;

select l.location_id, l.street_address,l.state_province, co.country_name from locations l
left outer join countries co on co.country_id = l.country_id;

select first_name, last_name, hire_date from employees where hire_date <(select hire_date from employees where employee_id = 34) order by last_name;

select hire_date from employees where employee_id = 34;

select cust_no, cname,country_cd from customers where lower(country_cd) like lower(substr('&country_cd%',1,2));

select c.cust_no,c.cname,o.order_no,o.order_dt,sum(ol.qty),sum(ol.price*ol.qty) from customers c
left outer join orders o on c.cust_no = o.cust_no
inner join orderlines ol on o.order_no = ol.order_no
where c.cust_no between 1010 and 1050
group by c.cust_no,c.cname,o.order_no,o.order_dt
having sum(ol.qty)>600
order by 6
;

select c.cname, round(sum(ol.qty*ol.price),-2) from customers c
left outer join orders o on o.cust_no = c.cust_no
left outer join orderlines ol on ol.order_no = o.order_no
group by c.cname
having sum(ol.qty*ol.price)>40000;


SELECT c.cname, ROUND(SUM(ol.qty * ol.price), -2)
FROM customers c
JOIN orders o ON c.cust_no = o.cust_no
JOIN orderlines ol ON o.order_no = ol.order_no
GROUP BY c.cname
HAVING SUM(ol.qty * ol.price) >= 40000;

select prod_name,prod_type,prod_sell from products where prod_type in (select prod_type from products where prod_sell = (select min(prod_sell) from products)) and prod_sell>10;

select distinct p.prod_name,p.prod_type,p.prod_sell from products p inner join (select prod_type from products where prod_sell = (select min(prod_sell) from products))alias on p.prod_type = alias.prod_type
where p.prod_sell>10
;


SELECT prod_name, prod_type, prod_sell
FROM products
WHERE prod_type IN (SELECT prod_type FROM products 
                    WHERE prod_sell = (SELECT MIN(prod_sell) FROM products))
AND prod_sell > 10;

select prod_type from products where prod_sell = (select min(prod_sell) from products) ;

select c.cust_no, cname, country_name 
from customers c, countries co, orders o
where substr(c.country_cd, 1,2) = co.country_id
and o.cust_no = c.cust_no
and co.country_name in ('United Kingdom', 'Germany')
and order_dt like '%14'
order by cust_no;

SELECT department_id, job_id, MIN (salary) 
FROM employEes JOIN departments  
     USING (department_id) 
WHERE upper(job_id) NOT LIKE '%REP%' 
 AND UPPER(department_name) NOT IN ('IT','SALES') -- must be names
GROUP BY department_id, job_id 
 HAVING MIN(salary) BETWEEN 6000 AND 18000  
ORDER BY 1, 2;  


select distinct c.cname,nvl(count(o.order_no),0) from customers c
left outer join orders o on c.cust_no = o.cust_no
where upper(c.cname) like ('A%') or upper(c.cname) like ('C%')
group by c.cname
order by c.cname;


select e.first_name,e.last_name, e.salary,j.grade 
from employees e,job_grades j
where e.salary between j.lowest_sal and j.highest_sal
and e.department_id not in(80,50,110)
;
 
 
 SELECT e1.last_name, e1.salary, e1.department_id, e2.last_name, e2.salary, e2.department_id



FROM employees e2 JOIN employees e1



ON e1.manager_id = m2.employee_id



AND e1.salary > (SELECT 7000 + AVG(salary) FROM employees);


   

select distinct
    c.cust_no,
    c.cname,
    o.order_no
from products p
inner join orderlines ol on p.prod_no=ol.prod_no
inner join orders o on ol.order_no=o.order_no
inner join customers c on c.cust_no=o.cust_no
where
   p.prod_no in (40301,40303,40300, 40310, 40306)
    AND
    lower(c.cname) like lower('%Outlet%') --  outlet anywhere
order by 1;


select distinct c.cust_no, c.cname,c.address1 from customers c
inner join orders o on o.cust_no = c.cust_no
inner join orderlines ol on ol.order_no = o.order_no
inner join products p on p.prod_no = ol.prod_no
where p.prod_no in(40300, 40303, 40310,40306)
and lower(c.cname) like lower('%SU%')  order by c.cust_no;


select c.cname, round(sum(ol.qty*ol.price),-2) from customers c
left outer join orders o on o.cust_no = c.cust_no
left outer join orderlines ol on ol.order_no = o.order_no
group by c.cname
having sum(ol.qty*ol.price)>40000;

select first_name, last_name, hire_date from employees 
where 
hire_date <(select hire_date from employees where employee_id = 34) 
order by last_name;


select distinct cust_no, cname,country_cd from customers 
where lower(country_cd) like lower(substr('&country_cd%',1,2));

select p.prod_name,p.prod_type,p.prod_sell from products p 
inner join 
(select prod_type from products where prod_sell = (select min(prod_sell) from products))alias 
on p.prod_type = alias.prod_type
where p.prod_sell>10
;

select c.cust_no,c.cname,o.order_no,o.order_dt,sum(ol.qty),sum(ol.price*ol.qty) from customers c
left outer join orders o on c.cust_no = o.cust_no
inner join orderlines ol on o.order_no = ol.order_no
where c.cust_no between 1010 and 1050
group by c.cust_no,c.cname,o.order_no,o.order_dt
having sum(ol.qty)>600
order by sum(ol.price*ol.qty)
;

select l.location_id, l.street_address,l.state_province from locations l
left outer join countries co on co.country_id = l.country_id;












SET PAGESIZE 200

select c.cname, round(sum(ol.qty*ol.price),-2) from customers c

join orders o on o.cust_no = c.cust_no

join orderlines ol on ol.order_no = o.order_no

group by c.cname

having sum(ol.qty*ol.price)>40000;

SET
   pagesize 200 
   SELECT
      first_name,
      last_name,
      hire_date 
   FROM
      employees 
   WHERE
      hire_date < (
      SELECT
         hire_date 
      FROM
         employees 
      WHERE
         employee_id = 34) 
      ORDER BY
         last_name;

SET
   pagesize 200 
   SELECT DISTINCT
      cust_no,
      cname,
      country_cd 
   FROM
      customers 
   WHERE
      LOWER(country_cd) LIKE LOWER(substr('&country_cd%', 1, 2));


SET
   pagesize 200 
   SELECT
      prod_name,
      prod_type,
      prod_sell 
   FROM
      products 
   WHERE
      prod_type IN 
      (
         SELECT
            prod_type 
         FROM
            products 
         WHERE
            prod_sell = 
            (
               SELECT
                  MIN(prod_sell) 
               FROM
                  products
            )
      )
      AND prod_sell > 10;



SET
   pagesize 200 
   SELECT distinct
      c.cust_no,
      c.cname,
      o.order_no,
      o.order_dt,
      SUM(ol.qty),
      SUM(ol.price*ol.qty) 
   FROM
      customers c 
      INNER JOIN
         orders o 
         ON c.cust_no = o.cust_no 
      INNER JOIN
         orderlines ol 
         ON o.order_no = ol.order_no 
   WHERE
      c.cust_no BETWEEN 1010 AND 1050 
   GROUP BY
      c.cust_no,
      c.cname,
      o.order_no,
      o.order_dt 
   HAVING
      SUM(ol.qty) > 600 
   ORDER BY
      SUM(ol.price*ol.qty) ;

SET
   pagesize 200 
   SELECT
      l.location_id,
      l.street_address,
      l.state_province,
      co.country_name
   FROM
      locations l 
      LEFT OUTER JOIN
         countries co 
         ON co.country_id = l.country_id;



