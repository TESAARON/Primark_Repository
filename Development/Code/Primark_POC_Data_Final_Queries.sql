
DROP TABLE IF EXISTS primark.poc_data_single_day;
CREATE TABLE primark.poc_data_single_day as
select * from 
	`primark`.`poc_data`
where `poc_data`.`Date` = '2015-6-6';




DROP TABLE IF EXISTS primark.Product_List;
CREATE TABLE primark.Product_List
select 
	a.`Item Style`
	, Trim(a.`Product Description`) as Product_Description
	, a.`Item Dept Description`
	, a.`Section Description`
    , case when b.`Item Style` is not null then 'Yes' else 'No' end as Top_25 
	, avg(a.`Item POS Price`/a.`Item Qty`) as price
	, count(*) as volume
	, avg(a.`Item POS Price`)*count(*) as volume_price
from `primark`.`poc_data_single_day` a
Left join
(
	select 
		`Item Style`	
		, Trim(`Product Description`) as Product_Description	
		, avg(`Item POS Price`/`Item Qty`) as price
		, count(*) as volume
		, avg(`Item POS Price`)*count(*) as volume_price
	from `primark`.`poc_data_single_day`
	where `Item Style` <> 1
	group by `Item Style`
		, Trim(`Product Description`)
	having price >= 7 
	order by volume_price desc
	limit 25
) b
on a.`Item Style` = b.`Item Style`
group by a.`Item Style`
	, Trim(a.`Product Description`)
    , a.`Item Dept Description`
	, a.`Section Description`
    , b.`Item Style`
order by volume_price desc;