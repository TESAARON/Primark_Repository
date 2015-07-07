DROP TABLE IF EXISTS primark.top_25_breakdown;
CREATE TABLE primark.top_25_breakdown
(
  Item_Style int(11) NOT NULL,
  perc_less_7 decimal(10,2) NOT NULL,
  perc_great_7 decimal(10,2) DEFAULT NULL
);

-- select * from primark.top_25_breakdown

DROP PROCEDURE IF EXISTS curdemo;

DELIMITER $$
CREATE PROCEDURE curdemo()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE item_style_parameter CHAR(16);
  DECLARE b INT;
  DECLARE cur1 CURSOR FOR 
							select `Item Style` 
                            from `primark`.`Product_List`
							where Top_25 = 'No';
							
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur1;

  read_loop: LOOP
    FETCH cur1 INTO item_style_parameter;
    IF done THEN
      LEAVE read_loop;
    END IF;

		-- Loop through values in where clause
				insert into primark.top_25_breakdown
				select c.Item_Style
                    , d.count_less_7*100/c.count as perc_less_7
                    , e.count_great_7*100/c.count as perc_great_7
				from
				(
					select item_style_parameter as Item_Style 
						, count(*) as count
					from 
						`primark`.`poc_data_single_day` a
					inner join
					(
						select distinct 
							`Unique Transaction ID` 
						from 
							`primark`.`poc_data_single_day`
						where `Item Style` = item_style_parameter
					) b 
					on a.`Unique Transaction ID` = b.`Unique Transaction ID`
				) c
				Left join
				(
					select item_style_parameter as Item_Style 
						, count(*) as count_less_7
					from 
						`primark`.`poc_data_single_day` a
					inner join
					(
						select distinct 
							`Unique Transaction ID` 
						from 
							`primark`.`poc_data_single_day`
						where `Item Style` = item_style_parameter
					) b 
					on a.`Unique Transaction ID` = b.`Unique Transaction ID`
					where `Item POS Price`/ `Item Qty` >= 7
				) d
				on c.Item_Style = d.Item_Style
				Left join
				(
					select item_style_parameter as Item_Style 
						, count(*) as count_great_7
					from 
						`primark`.`poc_data_single_day` a
					inner join
					(
						select distinct 
							`Unique Transaction ID` 
						from 
							`primark`.`poc_data_single_day`
						where `Item Style` = item_style_parameter
					) b 
					on a.`Unique Transaction ID` = b.`Unique Transaction ID`
					where `Item POS Price`/`Item Qty` < 7
				) e
				on c.Item_Style = e.Item_Style;

  END LOOP;

  CLOSE cur1;
  
END $$

DELIMITER ;

CALL curdemo();

 