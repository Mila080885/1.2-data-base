-- 1. БД позволяет хранить данные собранные со стороних ИМ (с помощью парсинга), 
-- данные нужны производителю для анализа рынка и создания продукта, который пользуется спросом
	
-- 2. Создание таблиц
DROP DATABASE IF EXISTS wld;
CREATE DATABASE IF NOT EXISTS wld;
USE wld;
SHOW TABLES;

DROP TABLE IF EXISTS products;
CREATE TABLE products (
  id INT UNSIGNED NOT NULL PRIMARY KEY,
  product_name VARCHAR(255) COMMENT 'Название',
  brand_id INT UNSIGNED,
  catalog_id INT UNSIGNED,
  link VARCHAR(120) NOT NULL UNIQUE COMMENT 'Ссылка',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
 );

CREATE INDEX products_catalog_id_idx ON products(catalog_id);
 
DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  catalog_name VARCHAR(255) COMMENT 'Название',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS brands;
CREATE TABLE brands (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  brand_name VARCHAR(255) COMMENT 'Название',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS characteristics_products;
CREATE TABLE characteristics_products (
  product_id INT UNSIGNED NOT NULL,
  color_id INT UNSIGNED,
  width SMALLINT,
  deep SMALLINT,
  height SMALLINT,
  unit_of_measure VARCHAR(15),
  weight SMALLINT,
  product_composition_id INT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
 );
CREATE INDEX ch_products_product_id_idx ON characteristics_products(product_id);

DROP TABLE IF EXISTS color_products;
CREATE TABLE color_products (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  color VARCHAR(25),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
 );


DROP TABLE IF EXISTS  product_composition;
CREATE TABLE product_composition (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  product_composition VARCHAR(25) COMMENT 'Состав продукта',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
 );

DROP TABLE IF EXISTS prices;
CREATE TABLE prices (
  product_id INT UNSIGNED NOT NULL,
  price DECIMAL (11,2) COMMENT 'Цена',
  sale_price DECIMAL (11,2) COMMENT 'Цена продажи со скидкой',
  sales_in_units INT UNSIGNED COMMENT 'Продажи в шт',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
CREATE INDEX prices_product_id_sale_price_sales_in_units_idx ON prices (product_id, sale_price, sales_in_units);

DROP TABLE IF EXISTS reviews;
CREATE TABLE reviews (
  product_id INT UNSIGNED NOT NULL,
  number_of_reviews INT UNSIGNED COMMENT 'Кол-во отзывов',
  date_of_the_first DATETIME COMMENT 'Дата первого отзыва',
  date_of_last DATETIME COMMENT 'Дата последнего отзыва',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  rating TINYINT COMMENT 'Кол-во звезд',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
CREATE INDEX reviews_product_id_date_of_the_first_idx ON reviews (product_id, date_of_the_first);
CREATE INDEX reviews_product_id_idx ON reviews (product_id);

-- скрипт для создания внешних ключей не сохранился, но связи остались, это видно на диаграмме

-- 5. Заполнение данных и корректировка
-- сгенерировала данные на  http://filldb.info, после удаления бд сделала дамб

SHOW TABLES;

SELECT * FROM brands LIMIT 10;
UPDATE brands SET created_at = '2020-01-01';

SELECT * FROM catalogs;
UPDATE catalogs SET created_at = '2020-01-01';

SELECT * FROM characteristics_products;
UPDATE characteristics_products SET unit_of_measure = 'см';
UPDATE characteristics_products SET created_at = '2020-01-01';

SELECT * FROM color_products;
UPDATE color_products SET created_at = '2020-01-01';

SELECT * FROM prices  LIMIT 10;
UPDATE prices SET created_at = '2020-01-01';
UPDATE prices SET sale_price = price*0.95;

SELECT * FROM product_composition;
UPDATE product_composition SET created_at = '2020-01-01';

SELECT * FROM products;
UPDATE products SET created_at = '2020-01-01';

SELECT * FROM reviews;
UPDATE reviews SET created_at = '2020-01-01';
UPDATE reviews SET rating = FLOOR(1 + (RAND () * 5));


-- 6. скрипты характерных выборок

-- 6.1 узнать 10 самых хорошо продаваемых товаров 
-- указать цену, и продажи в шт и руб., дату первого отзыва,  категорию товара и бренд
SELECT prices.product_id, 
       (SELECT catalog_name 
          FROM catalogs 
          WHERE id = products.catalog_id) AS catalogs,
       (SELECT brand_name 
          FROM brands 
          WHERE id = products.brand_id) AS brand,
       (prices.sales_in_units * prices.sale_price) AS sales_in_rubles,
       prices.sales_in_units, 
       prices.sale_price, 
       reviews.date_of_the_first     
FROM prices
  LEFT JOIN reviews
    ON prices.product_id = reviews.product_id
  JOIN products
    ON prices.product_id = products.id
WHERE prices.created_at = '2020-01-01'
ORDER BY sales_in_rubles DESC
LIMIT 10;



-- 6.2 сгрупировать данные по товарным категориям с указанием кол-ва артикулов, суммы продаж в шт и рублях 
SELECT catalogs.catalog_name,
       COUNT(*) AS number_of_articles,
       sum(prices.sales_in_units * prices.sale_price) AS sales_in_rubles,
       sum(prices.sales_in_units) AS sales_in_units,
       (sum(prices.sales_in_units * prices.sale_price) / sum(prices.sales_in_units)) AS average_price,
       (sum(prices.sales_in_units * prices.sale_price) / COUNT(products.id)) AS sales_1_article
FROM prices
  JOIN products
    ON prices.product_id = products.id
  JOIN catalogs
    ON products.catalog_id = catalogs.id
WHERE prices.created_at = '2020-01-01'
GROUP BY catalog_name
ORDER BY sales_in_rubles DESC;

-- найдем категорию, где продажи с 1 артикула больше, чем по другим категориям
SELECT catalogs.catalog_name,
       COUNT(*) AS number_of_articles,
       sum(prices.sales_in_units * prices.sale_price) AS sales_in_rubles,
       sum(prices.sales_in_units) AS sales_in_units,
       (sum(prices.sales_in_units * prices.sale_price) / sum(prices.sales_in_units)) AS average_price,
       (sum(prices.sales_in_units * prices.sale_price) / COUNT(products.id)) AS sales_1_article
FROM prices
  JOIN products
    ON prices.product_id = products.id
  JOIN catalogs
    ON products.catalog_id = catalogs.id
WHERE prices.created_at = '2020-01-01'
GROUP BY catalog_name
ORDER BY sales_1_article DESC
LIMIT 1;

-- 7. представления 
-- 7.1 создадим представление, позволяющее быстро получать основную инф-ю о товарах
CREATE OR REPLACE VIEW prod AS 
	SELECT prices.product_id, 
	       (SELECT catalog_name 
	          FROM catalogs 
	          WHERE id = products.catalog_id) AS catalogs,
	       (SELECT brand_name 
	          FROM brands 
	          WHERE id = products.brand_id) AS brand,
	       (prices.sales_in_units * prices.sale_price) AS sales_in_rubles,
	       prices.sales_in_units, 
	       prices.sale_price, 
	       reviews.date_of_the_first,
	       prices.created_at
	FROM prices
	  LEFT JOIN reviews
	    ON prices.product_id = reviews.product_id
	  JOIN products
	    ON prices.product_id = products.id;

-- и теперь запрос п. 6.1 выглядит компактно:  
SELECT *
FROM prod
WHERE created_at = '2020-01-01'
ORDER BY sales_in_rubles DESC
LIMIT 10;

-- 7.2 создадим представление, где будут товары с отзывами 
CREATE OR REPLACE VIEW products_with_reviews AS 
	SELECT reviews.product_id, 
	       (SELECT catalog_name 
	          FROM catalogs 
	          WHERE id = products.catalog_id) AS catalogs,
	       (SELECT brand_name 
	          FROM brands 
	          WHERE id = products.brand_id) AS brand,
	       reviews.number_of_reviews,
	       reviews.rating,
	       products.created_at
	FROM reviews
	  JOIN products
	    ON reviews.product_id = products.id
	WHERE reviews.number_of_reviews >0;
    
-- теперь найдем рейтинг по категориям 
SELECT catalogs, AVG(rating) AS rating_catalog
FROM products_with_reviews
WHERE created_at = '2020-01-01'
GROUP BY catalogs
ORDER BY rating_catalog DESC;

-- можно категорию заменить брендом, и добавить доп.показатели из представления
SELECT brand, AVG(rating) AS rating_brand, SUM(number_of_reviews), COUNT(product_id)
FROM products_with_reviews
WHERE created_at = '2020-01-01'
GROUP BY brand
ORDER BY rating_brand DESC;


