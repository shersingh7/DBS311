-- ***********************
-- Name: Davinder Verma
-- Student ID: 121802201
-- Date: 28-02-2021
-- Purpose: Lab 5 DBS311
-- ***********************

SET SERVEROUTPUT ON 


-- Question 1 – 
/* Write a stored procedure that get an integer number and prints
The number is even.
If a number is divisible by 2.
Otherwise, it prints 
The number is odd. */

-- Q1 SOLUTION: 
CREATE OR REPLACE PROCEDURE even_or_odd (num IN NUMBER) AS 
BEGIN 
IF mod(num, 2) = 0 THEN
    DBMS_OUTPUT.PUT_LINE('The number is even');
  ELSE
    DBMS_OUTPUT.PUT_LINE('The number is odd');
END IF;
EXCEPTION
WHEN OTHERS
  THEN 
      DBMS_OUTPUT.PUT_LINE ('Error!');
END even_or_odd;
/
EXECUTE even_or_odd(&value);


-- Question 2 – 
/* Create a stored procedure named find_employee. This procedure gets an 
employee number and prints the following employee information:
First name 
Last name 
Email
Phone 	
Hire date 
Job ID
The procedure gets a value as the employee ID of type NUMBER. */

-- Q2 SOLUTION:
CREATE OR REPLACE PROCEDURE 
find_employee (p_empID IN employees.employee_id%TYPE) AS 
p_firstName employees.first_name%TYPE;
p_lastName employees.last_name%TYPE;
p_email employees.email%TYPE;
p_phone employees.phone_number%TYPE;
p_hireDate employees.hire_date%TYPE;
p_jobTitle employees.job_id%TYPE;
BEGIN
SELECT first_name, last_name, email, 
       phone_number, hire_date, job_id
INTO   p_firstName, p_lastName, p_email, 
       p_phone, p_hireDate, p_jobTitle
FROM employees
WHERE employee_id = p_empID;
DBMS_OUTPUT.PUT_LINE ('First name: ' || p_firstName);
DBMS_OUTPUT.PUT_LINE ('Last name: ' || p_lastName);
DBMS_OUTPUT.PUT_LINE ('Email: ' || p_email);
DBMS_OUTPUT.PUT_LINE ('Phone: ' || p_phone);
DBMS_OUTPUT.PUT_LINE ('Hire date: ' || p_hireDate);
DBMS_OUTPUT.PUT_LINE ('Job title: ' || p_jobTitle);
EXCEPTION
WHEN TOO_MANY_ROWS THEN 
  DBMS_OUTPUT.PUT_LINE ('Too Many Employees Returned!');
WHEN NO_DATA_FOUND THEN 
  DBMS_OUTPUT.PUT_LINE ('No Employee Found!');
WHEN OTHERS THEN 
  DBMS_OUTPUT.PUT_LINE ('Error!');
END find_employee;
/
EXECUTE find_employee(&id);


-- Question 3 – 
/* Every year, the company increases the price of all products in one product type. 
For example, the company wants to increase the selling price of products in type Tents by $5. 
Write a procedure named update_price_tents to update the price of all products in the given type and the given amount to be added to the current selling price if the price is greater than 0. 
The procedure shows the number of updated rows if the update is successful.
The procedure gets two parameters:
•	Prod_type IN VARCHAR2
•	amount 	NUMBER(9,2)
 */

-- Q3 SOLUTION:

create or replace procedure
update_price_tents(
    pType in products.prod_type % type,
    pAmount in products.prod_sell % type)
    as pCount number;
begin
    -- Count number of products matching type
   select
      count(prod_type) into pCount 
   from
      products
   where
      prod_type = pType;
if (pAmount > 0 and pCount > 0) 
then
   update
      products
   set
      prod_sell = prod_sell + pAmount 
   where
      prod_type = pType;
    dbms_output.put_line('Rows Updated =' || SQL % rowcount);
else
   dbms_output.put_line('No type matches or input price is less than 0.');
end
if;
exception 
when
   no_data_found 
then
   dbms_output.put_line('Products not found.');
when
   others 
then
   dbms_output.put_line('Stored PROCEDURE has errors.');
end;
/
begin
   update_price_tents('Tents', 5);
end;
/
rollback;



-- Question 4 – 
/* Every year, the company increases the price of products by 1 or 2% (Example of 2% -- prod_sell * 1.02) based on if the selling price (prod_sell) is less than the average price of all products. 
Write a stored procedure named update_low_prices_123456789 where 123456789 is replaced by your student number.
This procedure does not have any parameters. You need to find the average sell price of all products and store it into a variable of the same data type. If the average price is less than or equal to $1000, then update the products selling price by 2% if that products sell price is less than the calculated average. 
If the average price is greater than $1000, then update products selling price by 1% if the price of the products selling price is less than the calculated average. 
The query displays an error message if any error occurs. Otherwise, it displays the number of updated rows.

 */

-- Q4 SOLUTION:
create
or replace procedure update_low_prices_123456789 as
average products.prod_sell%type;
rate number;
begin
select avg(prod_sell) into average from products ;
   if average >= 1000 then
       rate := 1.01;
   else
        rate :=1.02;
   end if;
   update products set prod_sell = prod_sell * rate where prod_sell <= average;
   DBMS_OUTPUT.PUT_LINE('Rows Updated =' || SQL%ROWCOUNT);  
exception
when no_data_found then
    DBMS_OUTPUT.PUT_LINE('No products found.');   
WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error!');     
end;
/
begin
   update_low_prices_123456789;
end;
/
rollback;


-- Question 5 – 
/* The company needs a report that shows three categories of products based their prices. The company needs to know if the product price is cheap, fair, or expensive. Let us assume that
	- If the list price is less than the (average sell price – minimum sell price) divided by 2
		The product’s price is LOW.
	- If the list price is greater than the maximum less the average divided by 2
	The product’ price is HIGH.
	- If the list price is between 
o	(average price – minimum price) / 2  AND   (maximum price – average price) / 2 INCLUSIVE
	The product’s price is fair.
Write a procedure named price_report_123456789  to show the number of products in each price category:

 */

-- Q5 SOLUTION:

create or replace procedure price_report_123456789 AS
    pAverage products.prod_sell%type;
    pMin products.prod_sell%type;
    pMax products.prod_sell%type;
    price products.prod_sell%type;
    low NUMBER := 0;
    fair NUMBER := 0;
    high NUMBER := 0;
begin
    -- Get min, max, avg from products, insert into variables:
    select min(prod_sell), max(prod_sell), avg(prod_sell)
    into pMin, pMax, pAverage
    from products;
    -- Calculate low    
    select count(*)
    into low
    FROM products
    WHERE prod_sell < (pAverage - pMin) / 2;
    -- Calculate fair
    select count(*)
    into fair
    from products
    where   prod_sell <= (pMax - pAverage) / 2
    and     prod_sell >= (pAverage - pMin) / 2;
    -- Calculate high    
    select count(*)
    into high
    from products
    where prod_sell > (pMax - pAverage) / 2;
    -- OUTPUT
    dbms_output.put_line ('Low:  '||low);
    dbms_output.put_line ('Fair: '||fair);    
    dbms_output.put_line ('High: '||high);
exception
when others then
    dbms_output.put_line ('Error!');
end;
/  
begin
  price_report_123456789();
end;
/
rollback;