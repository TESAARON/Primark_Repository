/*
select * from primark.Product_List
where Top_25 = 'Yes';

select 
	`Item Style`
	, Product_Description
	, price
	, volume
	, volume_price
from primark.Product_List
where `Store Name` = 'DUNDRUM' and Date = '2015-7-1' and price >= 7 
limit 25;

select `Item Style`
	, Product_Description
    , Top_25 
	, avg(price)
	, sum(volume)
	, avg(price)*sum(volume) as volume_price
from primark.Product_List
group by `Item Style`
	, Product_Description
    , Top_25
order by Top_25 desc, `Item Style`;

select * from primark.Product_List;

select count(*) from primark.poc_data_with_returns

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
, Pairing_Level VARCHAR(10)
);


DROP TABLE IF EXISTS primark.tbl_frequent_items_iteration;
CREATE TABLE primark.tbl_frequent_items_iteration
(
  Step int
, Pairing_Level VARCHAR(10)
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