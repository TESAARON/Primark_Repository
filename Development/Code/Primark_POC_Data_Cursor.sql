DROP TABLE IF EXISTS primark.top_25_breakdown;
CREATE TABLE primark.top_25_breakdown
(
  Item_Style int(11) NOT NULL,
  total_count int(11) NOT NULL,
  total_count_0_and_7 int(11) NOT NULL,
  total_count_7_and_above int(11) DEFAULT NULL
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
							where Top_25 = 'Yes';
							
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur1;

  read_loop: LOOP
    FETCH cur1 INTO item_style_parameter;
    IF done THEN
      LEAVE read_loop;
    END IF;

		-- Loop through values in where clause
				insert into primark.top_25_breakdown
				select  item_style_parameter as Item_Style
					, sum(b.count) as total_count
					, sum(c.count_0_and_7) as total_count_0_and_7
					, sum(d.count_7_and_above) as total_count_7_and_above
				from
					`primark`.`poc_data_single_day` a
				Left join
				(
					select `Unique Transaction ID`
						, count(*) as count
					from
						`primark`.`poc_data_single_day`
					group by `Unique Transaction ID`
				) b
				on
				a.`Unique Transaction ID` = b.`Unique Transaction ID`
				Left join
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
				Left join
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
				where a.`Item Style` = item_style_parameter;

  END LOOP;

  CLOSE cur1;
  
END $$

DELIMITER ;

CALL curdemo();