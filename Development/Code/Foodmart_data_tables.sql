-- Point of Sales data (86837 transactions)

/*
SELECT sales_fact_1997.product_id,
    sales_fact_1997.time_id,
    sales_fact_1997.customer_id,
    sales_fact_1997.promotion_id,
    sales_fact_1997.store_id,
    sales_fact_1997.store_sales,
    sales_fact_1997.store_cost,
    sales_fact_1997.unit_sales
FROM foodmart.sales_fact_1997
limit 10;

select count(distinct product_id) from 
foodmart.sales_fact_1997;

-- Customer data
SELECT customer.customer_id,
    customer.account_num,
    customer.lname,
    customer.fname,
    customer.mi,
    customer.address1,
    customer.address2,
    customer.address3,
    customer.address4,
    customer.city,
    customer.state_province,
    customer.postal_code,
    customer.country,
    customer.customer_region_id,
    customer.phone1,
    customer.phone2,
    customer.birthdate,
    customer.marital_status,
    customer.yearly_income,
    customer.gender,
    customer.total_children,
    customer.num_children_at_home,
    customer.education,
    customer.date_accnt_opened,
    customer.member_card,
    customer.occupation,
    customer.houseowner,
    customer.num_cars_owned
FROM foodmart.customer
limit 10;


-- Product Data
SELECT product.product_class_id,
    product.product_id,
    product.brand_name,
    product.product_name,
    product.SKU,
    product.SRP,
    product.gross_weight,
    product.net_weight,
    product.recyclable_package,
    product.low_fat,
    product.units_per_case,
    product.cases_per_pallet,
    product.shelf_width,
    product.shelf_height,
    product.shelf_depth
FROM foodmart.product
limit 10;


-- Product class
SELECT product_class.product_class_id,
    product_class.product_subcategory,
    product_class.product_category,
    product_class.product_department,
    product_class.product_family
FROM foodmart.product_class
limit 10;


-- specific time of day from code
SELECT time_by_day.time_id,
    time_by_day.the_date,
    time_by_day.the_day,
    time_by_day.the_month,
    time_by_day.the_year,
    time_by_day.day_of_month,
    time_by_day.week_of_year,
    time_by_day.month_of_year,
    time_by_day.quarter,
    time_by_day.fiscal_period
FROM foodmart.time_by_day
limit 10;

*/

DROP TABLE IF EXISTS foodmart.consolidated_data;
CREATE TABLE foodmart.consolidated_data as
SELECT concat(sales_fact.product_id, sales_fact.time_id, sales_fact.customer_id) as trans_id,
	sales_fact.product_id,
    sales_fact.time_id,
    sales_fact.customer_id,
    sales_fact.promotion_id,
    sales_fact.store_id,
    sales_fact.store_sales,
    sales_fact.store_cost,
    sales_fact.unit_sales,
    time_by_day.the_date,
    time_by_day.the_day,
    time_by_day.the_month,
    time_by_day.the_year,
    time_by_day.day_of_month,
    time_by_day.week_of_year,
    time_by_day.month_of_year,
    time_by_day.quarter,
    time_by_day.fiscal_period,
    customer.account_num,
    customer.lname,
    customer.fname,
    customer.mi,
    customer.city,
    customer.state_province,
    customer.postal_code,
    customer.country,
    customer_region_id,
    customer.birthdate,
    customer.marital_status,
    customer.yearly_income,
    customer.gender,
    customer.total_children,
    customer.num_children_at_home,
    customer.education,
    customer.date_accnt_opened,
    customer.member_card,
    customer.occupation,
    customer.houseowner,
    customer.num_cars_owned,
    product.brand_name,
    product.product_name,
    product.SKU,
    product.SRP,
    product.gross_weight,
    product.net_weight,
    product.recyclable_package,
    product.low_fat,
    product.units_per_case,
    product.cases_per_pallet,
    product.shelf_width,
    product.shelf_height,
    product.shelf_depth,
    product_class.product_subcategory,
    product_class.product_category,
    product_class.product_department,
    product_class.product_family
FROM foodmart.sales_fact_1997 sales_fact
LEFT JOIN
(
SELECT customer_id,
    account_num,
    lname,
    fname,
    mi,
    address1,
    address2,
    address3,
    address4,
    city,
    state_province,
    postal_code,
    country,
    customer_region_id,
    phone1,
    phone2,
    birthdate,
    marital_status,
    yearly_income,
    gender,
    total_children,
    num_children_at_home,
    education,
    date_accnt_opened,
    member_card,
    occupation,
    houseowner,
    num_cars_owned
FROM foodmart.customer
) customer
on sales_fact.customer_id = customer.customer_id
LEFT JOIN
(
SELECT product_class_id,
    product_id,
    brand_name,
    product_name,
    SKU,
    SRP,
    gross_weight,
    net_weight,
    recyclable_package,
    low_fat,
    units_per_case,
    cases_per_pallet,
    shelf_width,
    shelf_height,
    shelf_depth
FROM foodmart.product
) product
on sales_fact.product_id = product.product_id
LEFT JOIN
(
SELECT product_class_id,
    product_subcategory,
    product_category,
    product_department,
    product_family
FROM foodmart.product_class
) product_class
on product.product_class_id = product_class.product_class_id
LEFT JOIN
(
SELECT time_id,
    the_date,
    the_day,
    the_month,
    the_year,
    day_of_month,
    week_of_year,
    month_of_year,
    quarter,
    fiscal_period
FROM foodmart.time_by_day
) time_by_day
on sales_fact.time_id = time_by_day.time_id
LEFT JOIN
(
select distinct concat(product_id, time_id, customer_id) as trans_id
	,count(*)
from foodmart.sales_fact_1997
group by concat(product_id, time_id, customer_id)
having count(*) > 1
) duplicates
on concat(sales_fact.product_id, sales_fact.time_id, sales_fact.customer_id) = duplicates.trans_id
where duplicates.trans_id is null;



select * from foodmart.consolidated_data;




