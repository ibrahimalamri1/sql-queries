-- the data contains buyers of real estate (individuals \ government and commercial entities)
-- the main goal is to separate individual buyers from commercial and government entities into a new table
-- and do some cleaning along the way 
-- extracting the data we need from the orignal data source into a new table 
SELECT neighborhood,
       building_class_category,
       tax_class,
       address,
       year_built,
       residential_units,
       commercial_units,
       total_units,
       ownertype,
       ownername,
       tax_class_at_sale,
       building_class_at_sale,
       sale_price,
       sale_date,
       year_of_sale
INTO   brooklyn_newtable
FROM   brooklyn_realstate

------------------------------------------------------------------------
-- assinging the approprite data type to our coulmns 
SELECT DISTINCT year_built
FROM   brooklyn_newtable

SELECT Cast(year_built AS SMALLINT)
FROM   brooklyn_newtable

UPDATE brooklyn_newtable
SET    year_built = Cast(year_built AS SMALLINT)

ALTER TABLE brooklyn_newtable
  ADD year_built_int INT;

UPDATE brooklyn_newtable
SET    year_built_int = Cast(year_built AS INT)

UPDATE brooklyn_newtable
SET    residential_units = Cast(residential_units AS INT)

ALTER TABLE brooklyn_newtable
  ADD residential_units_int INT;

UPDATE brooklyn_newtable
SET    residential_units_int = Cast(residential_units AS INT)

UPDATE brooklyn_newtable
SET    commercial_units = Cast(commercial_units AS INT)

ALTER TABLE brooklyn_newtable
  ADD commercial_units_int INT;

UPDATE brooklyn_newtable
SET    commercial_units_int = Cast(commercial_units AS INT)

UPDATE brooklyn_newtable
SET    total_units = Cast(total_units AS INT)

ALTER TABLE brooklyn_newtable
  ADD total_units_int INT;

UPDATE brooklyn_newtable
SET    total_units_int = Cast(total_units AS INT)

UPDATE brooklyn_newtable
SET    sale_price = Cast(sale_price AS BIGINT)

ALTER TABLE brooklyn_newtable
  ADD sale_price_int BIGINT;

UPDATE brooklyn_newtable
SET    sale_price_int = Cast(sale_price AS BIGINT)

UPDATE brooklyn_newtable
SET    sale_date = Cast(sale_date AS DATE)

ALTER TABLE brooklyn_newtable
  ADD saledate DATE;

UPDATE brooklyn_newtable
SET    saledate = Cast(sale_date AS DATE)

-----------------------------------------------------
-- standrizing data in each coulomn (if needed)
SELECT DISTINCT building_class_category
FROM   brooklyn_newtable
ORDER  BY building_class_category DESC

UPDATE brooklyn_newtable
SET    building_class_category = Trim(building_class_category)

SELECT DISTINCT Replace(building_class_category, '  ', '_')
FROM   brooklyn_newtable

UPDATE brooklyn_newtable
SET    building_class_category = Replace(building_class_category, '  ', '_')

UPDATE brooklyn_newtable
SET    building_class_category = Replace(building_class_category, '_', ' ')

SELECT DISTINCT building_class_category
FROM   brooklyn_newtable

----------------------
USE mybase;

SELECT Replace(address, '  ', '_')
FROM   dbo.brooklyn_newtable

UPDATE brooklyn_newtable
SET    address = Replace(address, '  ', '_')

UPDATE brooklyn_newtable
SET    address = Replace(address, '_', ' ')

UPDATE brooklyn_newtable
SET    address = Trim(address)

SELECT DISTINCT building_class_at_sale
FROM   brooklyn_newtable

---- seprating indvisual buyers into a new coulmn called (owner) from commerical and gov entities 
ALTER TABLE brooklyn_newtable
  ADD owner NVARCHAR(255);

UPDATE brooklyn_newtable
SET    owner = ownername
WHERE  ownername NOT LIKE '% LLP%'
       AND ownername NOT LIKE '% LP%'
       AND ownername NOT LIKE '% llc%'
       AND ownername NOT LIKE '% corp%'
       AND ownername NOT LIKE '% inc%'
       AND ownername NOT LIKE '% ltd%'
       AND ownername NOT LIKE '% holdings%'
       AND ownername NOT LIKE '% group%'
       AND ownername LIKE '%,%'
       AND ownername NOT LIKE '%0%'
       AND ownername NOT LIKE '%1%'
       AND ownername NOT LIKE '%2%'
       AND ownername NOT LIKE '%3%'
       AND ownername NOT LIKE '%4%'
       AND ownername NOT LIKE '%5%'
       AND ownername NOT LIKE '%6%'
       AND ownername NOT LIKE '%7%'
       AND ownername NOT LIKE '%8%'
       AND ownername NOT LIKE '%9%'

-- sepreate owner first and last name into two seprate columns 
SELECT owner,
       LEFT(owner, Charindex(',', owner) - 1)           AS last_name,
       RIGHT(owner, Len(owner) - Charindex(',', owner)) AS first_name
FROM   brooklyn_newtable
WHERE  owner IS NOT NULL

ALTER TABLE brooklyn_newtable
  ADD last_name NVARCHAR(255);

UPDATE brooklyn_newtable
SET    last_name = LEFT(owner, Charindex(',', owner) - 1)

ALTER TABLE brooklyn_newtable
  ADD first_name NVARCHAR(255);

UPDATE brooklyn_newtable
SET    first_name = RIGHT(owner, Len(owner) - Charindex(',', owner))

USE mybase;

SELECT *
FROM   brooklyn_newtable
WHERE  first_name LIKE '% %'

UPDATE brooklyn_newtable
SET    first_name = Ltrim(first_name)

-- import the final revision of the data into a new table
SELECT neighborhood,
       building_class_category,
       tax_class,
       address,
       year_built_int,
       residential_units_int,
       commercial_units_int,
       total_units_int,
       tax_class_at_sale,
       building_class_at_sale,
       sale_price_int,
       saledate,
       first_name,
       last_name
INTO   individual_buyers
FROM   brooklyn_newtable
WHERE  first_name IS NOT NULL 
