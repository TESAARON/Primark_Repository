/*

DROP TABLE IF EXISTS primark.top_25_breakdown;
CREATE TABLE primark.top_25_breakdown
(
  Date CHAR(20),
  Item_Style CHAR(30),
  Product_Description CHAR(50),
  Item_Dept_Description CHAR(30),
  Section_Description CHAR(30),
  price decimal(10,2),
  volume int,
  volume_price decimal(10,2),
  avg_basket_items decimal(10,2),
  avg_basket_price decimal(10,2),
  perc_less_3 decimal(10,2),
  perc_3_to_7 decimal(10,2),
  perc_great_7 decimal(10,2),
  perc_hosiery decimal(10,2),
  perc_mens_accessories decimal(10,2),
  perc_menswear decimal(10,2),
  perc_kids_accessories decimal(10,2),
  perc_ladies_fashions decimal(10,2),
  perc_household decimal(10,2),
  perc_childrens_babywear decimal(10,2),
  perc_toiletries decimal(10,2),
  perc_ladies_lingerie decimal(10,2),
  perc_accessories decimal(10,2),
  perc_footwear decimal(10,2),
  perc_primarket decimal(10,2),
  perc_gift_card_sales decimal(10,2),
  perc_plastic_bag_levy decimal(10,2)
);

select * from primark.top_25_breakdown
order by Item_Style, Date;

select * from tbl_frequent_items_iteration
*/


DROP PROCEDURE IF EXISTS curdemo;

DELIMITER $$
CREATE PROCEDURE curdemo(IN analysis_date CHAR(20))
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE item_style_parameter CHAR(30);
  DECLARE cur1 CURSOR FOR 
                         
							select distinct `Item Style` 
                            from primark.Product_List
                            where Top_25 = 'Yes' and date = analysis_date;
                            							
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur1;

  read_loop: LOOP
    FETCH cur1 INTO item_style_parameter;
    IF done THEN
      LEAVE read_loop;
    END IF;

		-- Loop through values in where clause
				insert into primark.top_25_breakdown
				select analysis_date as Date
					, c.Item_Style
                    , d.Product_Description	
					, d.Item_Dept_Description
					, d.Section_Description
					, d.price
					, d.volume
					, d.volume_price
					, v.avg_basket_items
                    , v.avg_basket_price
                    , e.count_less_2*100/c.count as perc_less_2
                    , f.count_2_to_7*100/c.count as perc_2_to_7
                    , g.count_great_7*100/c.count as perc_great_7
                    , h.count_hosiery*100/c.count as perc_hosiery
                    , i.count_mens_accessories*100/c.count as perc_mens_accessories
                    , j.count_menswear*100/c.count as perc_menswear
                    , k.count_kids_accessories*100/c.count as perc_kids_accessories
                    , l.count_ladies_fashions*100/c.count as perc_ladies_fashions
                    , m.count_household*100/c.count as perc_household
                    , n.count_childrens_babywear*100/c.count as perc_childrens_babywear
                    , o.count_toiletries*100/c.count as perc_toiletries
                    , p.count_ladies_lingerie*100/c.count as perc_ladies_lingerie
                    , q.count_accessories*100/c.count as perc_accessories
                    , r.count_footwear*100/c.count as perc_footwear
                    , s.count_primarket*100/c.count as perc_primarket
                    , t.count_gift_card_sales*100/c.count as perc_gift_card_sales
                    , u.count_plastic_bag_levy*100/c.count as perc_plastic_bag_levy
				from
				(
					select item_style_parameter as Item_Style 
						, count(*) as count
					from 
						`primark`.`poc_data` a
					inner join
					(
						select distinct 
							`Unique Transaction ID` 
						from 
							`primark`.`poc_data`
						where `Item Style` = item_style_parameter and date = analysis_date
					) b 
					on a.`Unique Transaction ID` = b.`Unique Transaction ID`
					where `Item Style` <> item_style_parameter 
				) c
                Left join
				(
					select 
						`Item Style` as Item_Style	
						, Trim(`Product Description`) as Product_Description	
                        , `Item Dept Description` as Item_Dept_Description
						, `Section Description` as Section_Description
						, avg(`Item POS Price`/`Item Qty`) as price
						, count(*) as volume
						, avg(`Item POS Price`)*count(*) as volume_price
					from `primark`.`poc_data`
                    where `Item Style` = item_style_parameter and date = analysis_date
					group by `Item Style`
						, Trim(`Product Description`)
                        , `Item Dept Description`
						, `Section Description`
				) d
                on c.Item_Style = d.Item_Style
				Left join
				(
					select item_style_parameter as Item_Style 
						, count(*) as count_less_3
					from 
						`primark`.`poc_data` a
					inner join
					(
						select distinct 
							`Unique Transaction ID` 
						from 
							`primark`.`poc_data`
						where `Item Style` = item_style_parameter and date = analysis_date
					) b 
					on a.`Unique Transaction ID` = b.`Unique Transaction ID`
					where `Item POS Price`/ `Item Qty` < 3 and `Item Style` <> item_style_parameter
				) e
				on c.Item_Style = e.Item_Style
                Left join
				(
					select item_style_parameter as Item_Style 
						, count(*) as count_3_to_7
					from 
						`primark`.`poc_data` a
					inner join
					(
						select distinct 
							`Unique Transaction ID` 
						from 
							`primark`.`poc_data`
						where `Item Style` = item_style_parameter and date = analysis_date
					) b 
					on a.`Unique Transaction ID` = b.`Unique Transaction ID`
					where `Item POS Price`/ `Item Qty` >= 3 and `Item POS Price`/ `Item Qty` < 7 and `Item Style` <> item_style_parameter
				) f
				on c.Item_Style = f.Item_Style
				Left join
				(
					select item_style_parameter as Item_Style 
						, count(*) as count_great_7
					from 
						`primark`.`poc_data` a
					inner join
					(
						select distinct 
							`Unique Transaction ID` 
						from 
							`primark`.`poc_data`
						where `Item Style` = item_style_parameter and date = analysis_date
					) b 
					on a.`Unique Transaction ID` = b.`Unique Transaction ID`
					where `Item POS Price`/`Item Qty` >= 7 and `Item Style` <> item_style_parameter
				) g
				on c.Item_Style = g.Item_Style
                Left join
				(
					select item_style_parameter as Item_Style 
						, count(*) as count_hosiery
					from 
						`primark`.`poc_data` a
					inner join
					(
						select distinct 
							`Unique Transaction ID` 
						from 
							`primark`.`poc_data`
						where `Item Style` = item_style_parameter and date = analysis_date
					) b 
					on a.`Unique Transaction ID` = b.`Unique Transaction ID`
					where `Item Dept Description` = 'HOSIERY' and `Item Style` <> item_style_parameter
				) h
				on c.Item_Style = h.Item_Style
                Left join
				(
					select item_style_parameter as Item_Style 
						, count(*) as count_mens_accessories
					from 
						`primark`.`poc_data` a
					inner join
					(
						select distinct 
							`Unique Transaction ID` 
						from 
							`primark`.`poc_data`
						where `Item Style` = item_style_parameter and date = analysis_date
					) b 
					on a.`Unique Transaction ID` = b.`Unique Transaction ID`
					where `Item Dept Description` = 'MENS ACCESSORIES' and `Item Style` <> item_style_parameter
				) i
				on c.Item_Style = i.Item_Style
                Left join
				(
					select item_style_parameter as Item_Style 
						, count(*) as count_menswear
					from 
						`primark`.`poc_data` a
					inner join
					(
						select distinct 
							`Unique Transaction ID` 
						from 
							`primark`.`poc_data`
						where `Item Style` = item_style_parameter and date = analysis_date
					) b 
					on a.`Unique Transaction ID` = b.`Unique Transaction ID`
					where `Item Dept Description` = 'MENSWEAR' and `Item Style` <> item_style_parameter
				) j
				on c.Item_Style = j.Item_Style
                Left join
				(
					select item_style_parameter as Item_Style 
						, count(*) as count_kids_accessories
					from 
						`primark`.`poc_data` a
					inner join
					(
						select distinct 
							`Unique Transaction ID` 
						from 
							`primark`.`poc_data`
						where `Item Style` = item_style_parameter and date = analysis_date
					) b 
					on a.`Unique Transaction ID` = b.`Unique Transaction ID`
					where `Item Dept Description` = 'KIDS ACCESSORIES' and `Item Style` <> item_style_parameter
				) k
				on c.Item_Style = k.Item_Style
                Left join
				(
					select item_style_parameter as Item_Style 
						, count(*) as count_ladies_fashions
					from 
						`primark`.`poc_data` a
					inner join
					(
						select distinct 
							`Unique Transaction ID` 
						from 
							`primark`.`poc_data`
						where `Item Style` = item_style_parameter and date = analysis_date
					) b 
					on a.`Unique Transaction ID` = b.`Unique Transaction ID`
					where `Item Dept Description` = 'LADIES FASHIONS' and `Item Style` <> item_style_parameter
				) l
				on c.Item_Style = l.Item_Style
                Left join
				(
					select item_style_parameter as Item_Style 
						, count(*) as count_household
					from 
						`primark`.`poc_data` a
					inner join
					(
						select distinct 
							`Unique Transaction ID` 
						from 
							`primark`.`poc_data`
						where `Item Style` = item_style_parameter and date = analysis_date
					) b 
					on a.`Unique Transaction ID` = b.`Unique Transaction ID`
					where `Item Dept Description` = 'HOUSEHOLD' and `Item Style` <> item_style_parameter
				) m
				on c.Item_Style = m.Item_Style
                Left join
				(
					select item_style_parameter as Item_Style 
						, count(*) as count_childrens_babywear
					from 
						`primark`.`poc_data` a
					inner join
					(
						select distinct 
							`Unique Transaction ID` 
						from 
							`primark`.`poc_data`
						where `Item Style` = item_style_parameter and date = analysis_date
					) b 
					on a.`Unique Transaction ID` = b.`Unique Transaction ID`
					where `Item Dept Description` = 'CHILDRENS & BABYWEAR' and `Item Style` <> item_style_parameter
				) n
				on c.Item_Style = n.Item_Style
                Left join
				(
					select item_style_parameter as Item_Style 
						, count(*) as count_toiletries
					from 
						`primark`.`poc_data` a
					inner join
					(
						select distinct 
							`Unique Transaction ID` 
						from 
							`primark`.`poc_data`
						where `Item Style` = item_style_parameter and date = analysis_date
					) b 
					on a.`Unique Transaction ID` = b.`Unique Transaction ID`
					where `Item Dept Description` = 'TOILETRIES' and `Item Style` <> item_style_parameter
				) o
				on c.Item_Style = o.Item_Style
                Left join
				(
					select item_style_parameter as Item_Style 
						, count(*) as count_ladies_lingerie
					from 
						`primark`.`poc_data` a
					inner join
					(
						select distinct 
							`Unique Transaction ID` 
						from 
							`primark`.`poc_data`
						where `Item Style` = item_style_parameter and date = analysis_date
					) b 
					on a.`Unique Transaction ID` = b.`Unique Transaction ID`
					where `Item Dept Description` = 'LADIES LINGERIE' and `Item Style` <> item_style_parameter
				) p
				on c.Item_Style = p.Item_Style
                Left join
				(
					select item_style_parameter as Item_Style 
						, count(*) as count_accessories
					from 
						`primark`.`poc_data` a
					inner join
					(
						select distinct 
							`Unique Transaction ID` 
						from 
							`primark`.`poc_data`
						where `Item Style` = item_style_parameter and date = analysis_date
					) b 
					on a.`Unique Transaction ID` = b.`Unique Transaction ID`
					where `Item Dept Description` = 'ACCESSORIES' and `Item Style` <> item_style_parameter
				) q
				on c.Item_Style = q.Item_Style
                Left join
				(
					select item_style_parameter as Item_Style 
						, count(*) as count_footwear
					from 
						`primark`.`poc_data` a
					inner join
					(
						select distinct 
							`Unique Transaction ID` 
						from 
							`primark`.`poc_data`
						where `Item Style` = item_style_parameter and date = analysis_date
					) b 
					on a.`Unique Transaction ID` = b.`Unique Transaction ID`
					where `Item Dept Description` = 'FOOTWEAR' and `Item Style` <> item_style_parameter
				) r
				on c.Item_Style = r.Item_Style
                Left join
				(
					select item_style_parameter as Item_Style 
						, count(*) as count_primarket
					from 
						`primark`.`poc_data` a
					inner join
					(
						select distinct 
							`Unique Transaction ID` 
						from 
							`primark`.`poc_data`
						where `Item Style` = item_style_parameter and date = analysis_date
					) b 
					on a.`Unique Transaction ID` = b.`Unique Transaction ID`
					where `Item Dept Description` = 'PRIMARKET' and `Item Style` <> item_style_parameter
				) s
				on c.Item_Style = s.Item_Style
                Left join
				(
					select item_style_parameter as Item_Style 
						, count(*) as count_gift_card_sales
					from 
						`primark`.`poc_data` a
					inner join
					(
						select distinct 
							`Unique Transaction ID` 
						from 
							`primark`.`poc_data`
						where `Item Style` = item_style_parameter and date = analysis_date
					) b 
					on a.`Unique Transaction ID` = b.`Unique Transaction ID`
					where `Item Dept Description` = 'GIFT CARD SALES' and `Item Style` <> item_style_parameter
				) t
				on c.Item_Style = t.Item_Style
                Left join
				(
					select item_style_parameter as Item_Style 
						, count(*) as count_plastic_bag_levy
					from 
						`primark`.`poc_data` a
					inner join
					(
						select distinct 
							`Unique Transaction ID` 
						from 
							`primark`.`poc_data`
						where `Item Style` = item_style_parameter and date = analysis_date
					) b 
					on a.`Unique Transaction ID` = b.`Unique Transaction ID`
					where `Item Dept Description` = 'PLASTIC BAG LEVY' and `Item Style` <> item_style_parameter
				) u
				on c.Item_Style = u.Item_Style
                Left join
                (
					select item_style_parameter as Item_Style
						, avg(c.line_count) as avg_basket_items
						, avg(c.pos_price) as avg_basket_price
					from
					(
						select 
							a.`Unique Transaction ID`
							, count(*) as line_count
							, sum(`Item POS Price`) as pos_price
						from `primark`.`poc_data` a
						inner join
						(	
							select distinct 
								`Unique Transaction ID`
							from `primark`.`poc_data`
							where `Item Style` = item_style_parameter and date = analysis_date
						) b
						on a.`Unique Transaction ID` = b.`Unique Transaction ID`
						where `Item Style` <> item_style_parameter
						group by a.`Unique Transaction ID`
					) c
                ) v
                on c.Item_Style = v.Item_Style;

  END LOOP;

  CLOSE cur1;
  
END $$

DELIMITER ;

-- CALL curdemo('2015-7-1');














 