/*

DROP TABLE IF EXISTS primark.poc_data_with_returns;
DROP TABLE IF EXISTS primark.poc_data;

select * from primark.Product_List;

select count(*) from primark.poc_data_with_returns;

select count(*) from primark.poc_data;

select * from tbl_frequent_items_iteration

*/


DROP TABLE IF EXISTS primark.tmp_frequent_items;
CREATE TABLE primark.tmp_frequent_items
(
  Items_1 int
, Items_2 int
, Frequency int
, Support DECIMAL(18,9)
, Product_Description_1 VARCHAR(255)
, Top_25_1 VARCHAR(10)
, price_1 DECIMAL(18,9)
, Product_Description_2 VARCHAR(255)
, Top_25_2 VARCHAR(10)
, price_2 DECIMAL(18,9)
, Step int
, Pairing_Level VARCHAR(50)
);


DROP TABLE IF EXISTS primark.tbl_frequent_items_iteration;
CREATE TABLE primark.tbl_frequent_items_iteration
(
  Step int
, Pairing_Level VARCHAR(50)
, Items_1 int
, Product_Description_1 VARCHAR(255)
, Items_2 int
, Product_Description_2 VARCHAR(255)
, price_1 DECIMAL(18,9)
, price_2 DECIMAL(18,9)
, Frequency int
, Support DECIMAL(18,9)
);


DROP TABLE IF EXISTS primark.Product_List;
CREATE TABLE primark.Product_List
select 
	a.`Store Name`
    , a.Date
	, a.`Item Style`
	, Trim(a.`Product Description`) as Product_Description
    , case when b.`Item Style` is not null then 'Yes' else 'No' end as Top_25 
	, avg(a.`Item POS Price`/a.`Item Qty`) as price
	, count(*) as volume
	, avg(a.`Item POS Price`)*count(*) as volume_price
from `primark`.`poc_data` a
Left join
(
	select 
		`Item Style`
		, Trim(`Product Description`) as Product_Description
		, avg(`Item POS Price`/`Item Qty`) as price
		, count(*) as volume
		, avg(`Item POS Price`)*count(*) as volume_price
	from `primark`.`poc_data`
	where `Item Style` <> 1
	group by `Item Style`
		, Trim(`Product Description`)
	having price >= 7 
	order by volume_price desc
	limit 25
) b
on a.`Item Style` = b.`Item Style`
group by a.`Store Name`
    , a.Date
	, a.`Item Style`
	, Trim(`Product Description`)
    , b.`Item Style`
order by a.`Store Name`
    , a.Date
    , volume_price desc;
    
    
-- Customer Segmentation query for customers who buy a top 25 item
select 'Top25_All' as Type
	, count(distinct e.`Unique Transaction ID`) as total_customers
	, sum(e.volume) as total_item_transactions
	, avg(e.volume) as avg_basket_items
	, sum(e.price) as total_sales
    , avg(e.price) as avg_basket_value
from
(
select d.`Unique Transaction ID`
	, count(*) as volume
    , sum(`Item POS Price`) as price 
from `primark`.`poc_data`d
Left join
(
	select distinct a.`Unique Transaction ID`
	from `primark`.`poc_data` a
	inner join
	(
		select distinct `Item Style` 
			from primark.Product_List
		where Top_25 = 'Yes'
	) b
	on a.`Item Style` = b.`Item Style` 
) c
on d.`Unique Transaction ID` = c.`Unique Transaction ID`  
where c.`Unique Transaction ID` is not null -- and `Item POS Price`/`Item Qty` < 3
group by d.`Unique Transaction ID`
) e
union all 
select 'Top25_less_3' as Type
	, count(distinct e.`Unique Transaction ID`) as total_customers
	, sum(e.volume) as total_item_transactions
	, avg(e.volume) as avg_basket_items
	, sum(e.price) as total_sales
    , avg(e.price) as avg_basket_value
from
(
select d.`Unique Transaction ID`
	, count(*) as volume
    , sum(`Item POS Price`) as price 
from `primark`.`poc_data`d
Left join
(
	select distinct a.`Unique Transaction ID`
	from `primark`.`poc_data` a
	inner join
	(
		select distinct `Item Style` 
			from primark.Product_List
		where Top_25 = 'Yes'
	) b
	on a.`Item Style` = b.`Item Style` 
) c
on d.`Unique Transaction ID` = c.`Unique Transaction ID`  
where c.`Unique Transaction ID` is not null and `Item POS Price`/`Item Qty` < 3
group by d.`Unique Transaction ID`
) e
union all 
select 'Top25_3_to_7' as Type
	, count(distinct e.`Unique Transaction ID`) as total_customers
	, sum(e.volume) as total_item_transactions
	, avg(e.volume) as avg_basket_items
	, sum(e.price) as total_sales
    , avg(e.price) as avg_basket_value
from
(
select d.`Unique Transaction ID`
	, count(*) as volume
    , sum(`Item POS Price`) as price 
from `primark`.`poc_data`d
Left join
(
	select distinct a.`Unique Transaction ID`
	from `primark`.`poc_data` a
	inner join
	(
		select distinct `Item Style` 
			from primark.Product_List
		where Top_25 = 'Yes'
	) b
	on a.`Item Style` = b.`Item Style` 
) c
on d.`Unique Transaction ID` = c.`Unique Transaction ID`  
where c.`Unique Transaction ID` is not null and `Item POS Price`/`Item Qty` >= 3 and `Item POS Price`/`Item Qty` < 7
group by d.`Unique Transaction ID`
) e
union all 
select 'Top25_great_7' as Type
	, count(distinct e.`Unique Transaction ID`) as total_customers
	, sum(e.volume) as total_item_transactions
	, avg(e.volume) as avg_basket_items
	, sum(e.price) as total_sales
    , avg(e.price) as avg_basket_value
from
(
select d.`Unique Transaction ID`
	, count(*) as volume
    , sum(`Item POS Price`) as price 
from `primark`.`poc_data`d
Left join
(
	select distinct a.`Unique Transaction ID`
	from `primark`.`poc_data` a
	inner join
	(
		select distinct `Item Style` 
			from primark.Product_List
		where Top_25 = 'Yes'
	) b
	on a.`Item Style` = b.`Item Style` 
) c
on d.`Unique Transaction ID` = c.`Unique Transaction ID`  
where c.`Unique Transaction ID` is not null and `Item POS Price`/`Item Qty` >= 7
group by d.`Unique Transaction ID`
) e;



-- Customer Segmentation query for customers who don't buy a top 25 item
select 'NotTop25_All' as Type
	, count(distinct e.`Unique Transaction ID`) as total_customers
	, sum(e.volume) as total_item_transactions
	, avg(e.volume) as avg_basket_items
	, sum(e.price) as total_sales
    , avg(e.price) as avg_basket_value
from
(
select d.`Unique Transaction ID`
	, count(*) as volume
    , sum(`Item POS Price`) as price 
from `primark`.`poc_data`d
Left join
(
	select distinct a.`Unique Transaction ID`
	from `primark`.`poc_data` a
	inner join
	(
		select distinct `Item Style` 
			from primark.Product_List
		where Top_25 = 'Yes'
	) b
	on a.`Item Style` = b.`Item Style` 
) c
on d.`Unique Transaction ID` = c.`Unique Transaction ID`  
where c.`Unique Transaction ID` is null -- and `Item POS Price`/`Item Qty` < 3
group by d.`Unique Transaction ID`
) e
union all 
select 'NotTop25_less_3' as Type
	, count(distinct e.`Unique Transaction ID`) as total_customers
	, sum(e.volume) as total_item_transactions
	, avg(e.volume) as avg_basket_items
	, sum(e.price) as total_sales
    , avg(e.price) as avg_basket_value
from
(
select d.`Unique Transaction ID`
	, count(*) as volume
    , sum(`Item POS Price`) as price 
from `primark`.`poc_data`d
Left join
(
	select distinct a.`Unique Transaction ID`
	from `primark`.`poc_data` a
	inner join
	(
		select distinct `Item Style` 
			from primark.Product_List
		where Top_25 = 'Yes'
	) b
	on a.`Item Style` = b.`Item Style` 
) c
on d.`Unique Transaction ID` = c.`Unique Transaction ID`  
where c.`Unique Transaction ID` is null and `Item POS Price`/`Item Qty` < 3
group by d.`Unique Transaction ID`
) e
union all 
select 'NotTop25_3_to_7' as Type
	, count(distinct e.`Unique Transaction ID`) as total_customers
	, sum(e.volume) as total_item_transactions
	, avg(e.volume) as avg_basket_items
	, sum(e.price) as total_sales
    , avg(e.price) as avg_basket_value
from
(
select d.`Unique Transaction ID`
	, count(*) as volume
    , sum(`Item POS Price`) as price 
from `primark`.`poc_data`d
Left join
(
	select distinct a.`Unique Transaction ID`
	from `primark`.`poc_data` a
	inner join
	(
		select distinct `Item Style` 
			from primark.Product_List
		where Top_25 = 'Yes'
	) b
	on a.`Item Style` = b.`Item Style` 
) c
on d.`Unique Transaction ID` = c.`Unique Transaction ID`  
where c.`Unique Transaction ID` is null and `Item POS Price`/`Item Qty` >= 3 and `Item POS Price`/`Item Qty` < 7
group by d.`Unique Transaction ID`
) e
union all 
select 'NotTop25_great_7' as Type
	, count(distinct e.`Unique Transaction ID`) as total_customers
	, sum(e.volume) as total_item_transactions
	, avg(e.volume) as avg_basket_items
	, sum(e.price) as total_sales
    , avg(e.price) as avg_basket_value
from
(
select d.`Unique Transaction ID`
	, count(*) as volume
    , sum(`Item POS Price`) as price 
from `primark`.`poc_data`d
Left join
(
	select distinct a.`Unique Transaction ID`
	from `primark`.`poc_data` a
	inner join
	(
		select distinct `Item Style` 
			from primark.Product_List
		where Top_25 = 'Yes'
	) b
	on a.`Item Style` = b.`Item Style` 
) c
on d.`Unique Transaction ID` = c.`Unique Transaction ID`  
where c.`Unique Transaction ID` is null and `Item POS Price`/`Item Qty` >= 7
group by d.`Unique Transaction ID`
) e;