-- create schema primark;
Create table `primark`.`old_poc_data`
SELECT `poc_data`.`Unique Transaction ID`,
    `poc_data`.`Date`,
    `poc_data`.`Time`,
    `poc_data`.`Store No`,
    `poc_data`.`Store Name`,
    `poc_data`.`Item Dept Description`,
    `poc_data`.`Section Description`,
    `poc_data`.`Product Description`,
    `poc_data`.`Item Style`,
    `poc_data`.`Item Product Code`,
    `poc_data`.`Item Qty`,
    `poc_data`.`Item POS Price`
FROM `primark`.`poc_data`
where `Unique Transaction ID` = '20150606_42_10_107863'
limit 10000;

select date, count(*)
from `primark`.`poc_data`
group by date;


DROP TABLE IF EXISTS primark.poc_data;
CREATE TABLE primark.poc_data_single_day as
select * from 
	`primark`.`poc_data_single_day`
where `Item Style` = 12071;


select * from 
	`primark`.`poc_data`
where `poc_data`.`Date` = '2015-6-7';

select a.`Unique Transaction ID`
	, sum(a.`one`)
    , sum(a.`two`)
    -- , sum(a.`three`)
from
(
select `Unique Transaction ID`
	, case when `Product Description` = 'SALLY HANSEN ABL' then 1 else 0 end as 'one'
	, case when  `Product Description` = 'IMAGINATION APPLIC' then 1 else 0 end as 'two'
    -- , case when  `Product Description` = 'V NECK VISCOSE TEE' then 1 else 0 end as 'three'
from `primark`.`poc_data`
) a
group by a.`Unique Transaction ID`
having sum(a.`one`) > 0 
	and sum(a.`two`) > 0
    -- and sum(a.`three`) > 0
;




DROP TABLE IF EXISTS primark.Top_25_Product;
CREATE TABLE primark.Top_25_Product as
select d.* 
from `primark`.`poc_data` d
inner join
(
select distinct a.`Unique Transaction ID`
from
	`primark`.`poc_data` a
inner join 
(
	select 
		 c.`Product Description`
		, c.price
		, c.volume
	from
	(
		select 
			`Item Style`
			, Product_Description
			, price
			, volume
            , volume_price
		from primark.Product_List
		where price >= 7 and `Item Style` <> 1
        limit 25
	) c
) b
on a.`Product Description` = b.`Product Description`
) e
on
d.`Unique Transaction ID`  = e.`Unique Transaction ID` ;


select * from primark.Product_List


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
order by volume_price desc;


select 12071 as Item_Style
	, avg(c.line_count) as avg_basket_items
    , avg(c.pos_price) as avg_basket_price
from
(
select 
	a.`Unique Transaction ID`
	, count(*) as line_count
	, sum(`Item POS Price`) as pos_price
from `primark`.`poc_data_single_day` a
inner join
(	
	select distinct 
		`Unique Transaction ID`
	from `primark`.`poc_data_single_day`
    where `Item Style` = 12071
) b
on a.`Unique Transaction ID` = b.`Unique Transaction ID`
where `Item Style` <> 12071
group by a.`Unique Transaction ID`
) c;




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
)



SELECT
	Step
	, Items_1
	, Product_Description_1
	, Items_2
	, Product_Description_2
	, price_1
	, price_2
	, Frequency
	, Support
FROM
(
    SELECT
		Step
		, Items_1
		, Product_Description_1
		, Top_25_1
		, Items_2
		, Product_Description_2
		, Top_25_2
		, price_1
		, price_2
		, Frequency
		, Support
        , @rn := IF(@prev = Items_1, @rn + 1, 1) AS rn
        , @prev := Items_1
    FROM primark.tmp_frequent_items
    JOIN (SELECT @prev := NULL, @rn := 0) AS vars
    WHERE Top_25_1 = 'Yes' and price_2 > 2
    ORDER BY Items_1, Frequency DESC, price_2 DESC
) AS T1
WHERE rn <= 3;



DROP TABLE IF EXISTS primark.tbl_frequent_items_iteration;
CREATE TABLE primark.tbl_frequent_items_iteration
(
  Step int
, Items_1 int
, Product_Description_1 VARCHAR(255)
, Items_2 int
, Product_Description_2 VARCHAR(255)
, price_1 DECIMAL(18,9)
, price_2 DECIMAL(18,9)
, Frequency int
, Support DECIMAL(18,9)
)

select * from primark.tbl_frequent_items_iteration

select * from tmp_frequent_items

select distinct items_2 from primark.tbl_frequent_items_iteration

select `Item Style` from `primark`.`Product_List`
where Top_25 = 'Yes';



-- Old Query to enter cursor for count of item styles 
select c.Item_Style
	, c.count
    , d.count_less_7
	, e.count_great_7
from
(
	select 12071 as Item_Style 
		, count(*) as count
	from 
		`primark`.`poc_data_single_day` a
	inner join
	(
		select distinct 
			`Unique Transaction ID` 
		from 
			`primark`.`poc_data_single_day`
		where `Item Style` = 12071
	) b 
	on a.`Unique Transaction ID` = b.`Unique Transaction ID`
) c
Left join
(
	select 12071 as Item_Style 
		, count(*) as count_less_7
	from 
		`primark`.`poc_data_single_day` a
	inner join
	(
		select distinct 
			`Unique Transaction ID` 
		from 
			`primark`.`poc_data_single_day`
		where `Item Style` = 12071
	) b 
	on a.`Unique Transaction ID` = b.`Unique Transaction ID`
	where `Item POS Price`/ `Item Qty` >= 7
) d
on c.Item_Style = d.Item_Style
Left join
(
	select 12071 as Item_Style 
		, count(*) as count_great_7
	from 
		`primark`.`poc_data_single_day` a
	inner join
	(
		select distinct 
			`Unique Transaction ID` 
		from 
			`primark`.`poc_data_single_day`
		where `Item Style` = 12071
	) b 
	on a.`Unique Transaction ID` = b.`Unique Transaction ID`
	where `Item POS Price`/`Item Qty` < 7
) e
on c.Item_Style = e.Item_Style;




select distinct 
	f.*
	, g.line_count
from `primark`.`poc_data_single_day` f
inner join
(
	select d.`Unique Transaction ID`
		, count(*) as line_count
	from 
	(	
		select distinct 
		`Unique Transaction ID`
		, `Date`
		, `Time`
		, `Store No`
		, `Store Name`
		, `Item Dept Description`
		, `Section Description`
		, `Product Description`
		, `Item Style`
		, `Item Qty`
		, `Item POS Price`
        from `primark`.`poc_data_single_day`
	) d
	group by d.`Unique Transaction ID`
) g
on f.`Unique Transaction ID` =  g.`Unique Transaction ID` 





-- Old Query to enter cursor for count of item styles 
select  12071 as Item_Style
	, sum(b.count) as total_count
    , sum(c.count_0_and_7) as total_count_0_and_7
    , sum(d.count_7_and_above) as total_count_7_and_above
from
	`primark`.`poc_data_single_day` a
inner join
(
	select `Unique Transaction ID`
		, count(*) as count
	from
		`primark`.`poc_data_single_day`
	group by `Unique Transaction ID`
) b
on
a.`Unique Transaction ID` = b.`Unique Transaction ID`
inner join
(
	select `Unique Transaction ID`
		, count(*) as count_0_and_7
	from
		`primark`.`poc_data_single_day`
	where `Item POS Price` < 7
	group by `Unique Transaction ID`
) c
on
a.`Unique Transaction ID` = c.`Unique Transaction ID`
inner join
(
	select `Unique Transaction ID`
		, count(*) as count_7_and_above
	from
		`primark`.`poc_data_single_day`
	where `Item POS Price` >= 7
	group by `Unique Transaction ID`
) d
on
a.`Unique Transaction ID` = d.`Unique Transaction ID`
where a.`Item Style` = 12071








-- Average basket for customers who buy a top 25 item
select g.`Unique Transaction ID`
	, avg(g.basket_items)
	, avg(g.basket_value)
from
(
select d.* 
	, f.basket_items
    , f.basket_value
from `primark`.`poc_data_single_day` d
inner join
(
select distinct a.`Unique Transaction ID`
from
	`primark`.`poc_data_single_day` a
inner join 
(
	select 
		 c.Product_Description
		, c.price
		, c.volume
	from
	(
		select 
			`Item Style`
			, Product_Description
			, price
			, volume
            , volume_price
		from primark.Product_List
		where price >= 7 and `Item Style` <> 1
        limit 25
	) c
) b
on a.`Product Description` = b.Product_Description
) e
on
d.`Unique Transaction ID`  = e.`Unique Transaction ID` 
Left join
(
	select `Unique Transaction ID`
		, count(*) as basket_items
        , sum(`Item POS Price`) as basket_value
	from `primark`.`poc_data_single_day`
    group by `Unique Transaction ID`
) f
on 
d.`Unique Transaction ID` = f.`Unique Transaction ID`
) g
group by g.`Unique Transaction ID`;





-- Average basket for customers who don't buy a top 25 item
select g.`Unique Transaction ID`
	, avg(g.basket_items)
	, avg(g.basket_value)
from
(
select d.* 
	, f.basket_items
    , f.basket_value
from `primark`.`poc_data_single_day` d
inner join
(
select distinct a.`Unique Transaction ID`
from
	`primark`.`poc_data_single_day` a
inner join 
(
	select 
		 c.Product_Description
		, c.price
		, c.volume
	from
	(
		select 
			`Item Style`
			, Product_Description
			, price
			, volume
            , volume_price
		from primark.Product_List
		where Top_25 = 'Yes'
	) c
) b
on a.`Product Description` = b.Product_Description
) e
on
d.`Unique Transaction ID`  = e.`Unique Transaction ID` 
Left join
(
	select `Unique Transaction ID`
		, count(*) as basket_items
        , sum(`Item POS Price`) as basket_value
	from `primark`.`poc_data_single_day`
    group by `Unique Transaction ID`
) f
on 
d.`Unique Transaction ID` = f.`Unique Transaction ID`
) g
group by g.`Unique Transaction ID`;



select avg(a.count)
from
(
select `Unique Transaction ID`
	, COUNT(*) as count
FROM `primark`.`poc_data_single_day`
group by `Unique Transaction ID`
) a;

select a.*
from primark.poc_data a
inner join
(
select distinct `Unique Transaction ID`
from primark.poc_data
where `Item Style` = 10712 and date = '2015-7-1'
) b
on a.`Unique Transaction ID` = b.`Unique Transaction ID`

select 
	`Item Style` as Item_Style	
	, count(*) as volume
from `primark`.`poc_data_single_day`
where `Item Style` = 25503
group by `Item Style`

select * from `primark`.`poc_data_single_day`
where `Item Style` = 25503


select sum(a.volume)
	,sum(a.basket_price)
    ,avg(a.volume)
from
(
select `Unique Transaction ID`
	,Count(*) as volume
    ,sum(`Item POS Price`) as basket_price
from `primark`.`poc_data`
group by `Unique Transaction ID`
) a




select d.*
from `primark`.`poc_data`d
inner join
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



select sum(e.volume)
	, avg(e.volume)
	, sum(e.price)
    , avg(e.price)
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


select date
	, `Store No`
    , `Store Name` 
    , count(*) 
from 
primark.poc_data
group by date
	, `Store No`
    , `Store Name`
order by 
	`Store No`
    , date

