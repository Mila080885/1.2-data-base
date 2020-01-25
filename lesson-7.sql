-- ДЗ 6 урока (не успела сдать ранее)
-- 1. видоизменила решение заданий 
-- 1/1 Выбираем друзей пользователя с двух сторон отношения дружбы с активным статусом
USE vk;

SELECT user_id, friend_id, status_id FROM friendship
  WHERE (user_id = 8 OR friend_id = 8)
    AND status_id  = 2;

-- 1/2 Выбираем медиафайлы друзей
SELECT filename FROM media WHERE user_id IN ((SELECT user_id FROM friendship
  WHERE friend_id = 8 AND status_id  = 2) UNION (SELECT friend_id FROM friendship
  WHERE user_id = 8 AND status_id  = 2));

  -- 1.3 --  Объединяем медиафайлы пользователя и его друзей для создания ленты новостей
SELECT filename, user_id, created_at FROM media WHERE user_id = 8
UNION
SELECT filename, user_id, created_at FROM media WHERE user_id IN ((SELECT user_id FROM friendship
  WHERE friend_id = 8 AND status_id  = 2) UNION (SELECT friend_id FROM friendship
  WHERE user_id = 8 AND status_id  = 2));

-- 2.Пусть задан некоторый пользователь.Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.
SELECT from_user_id, COUNT(*) AS total_messages
FROM messages 
WHERE to_user_id = 8 
  AND from_user_id IN (
    SELECT friend_id AS id FROM friendship WHERE user_id = to_user_id AND status_id  = 2
    UNION
    SELECT user_id AS id FROM friendship WHERE user_id = to_user_id AND status_id  = 2   
    )
GROUP BY messages.from_user_id
ORDER BY total_messages DESC
LIMIT 1;



-- 3. Подсчитать общее количество лайков, которые получили 10 (взяла  30, т.к. при 10 = 1) самых молодых пользователей. 
-- Решение посмотрела на уроке 8, т.к. сама не смогла решить и даже в таком виде для меня сложен.
SELECT SUM(likes_per_user) AS likes_total FROM ( 
  SELECT COUNT(*) AS likes_per_user 
    FROM likes 
      WHERE target_type_id = 2
        AND target_id IN (
          SELECT * FROM (
            SELECT user_id FROM profiles ORDER BY birthday DESC LIMIT 30
          ) AS sorted_profiles 
        ) 
      GROUP BY target_id
) AS counted_likes;

-- 4. Определить кто больше поставил лайков (всего) - мужчины или женщины?
SELECT sex, COUNT(*) as likes_count 
FROM (
  SELECT likes.user_id,
    (SELECT profiles.sex 
     FROM profiles 
     WHERE profiles.user_id = likes.user_id) as 'sex'
  FROM likes) as dummy_table 
GROUP BY sex
ORDER BY likes_count DESC;

 -- 5. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети
 -- я взяла выборку из 10 самых раних пользователей и уже смотрела кто из них проявляет меньшую активность       
SELECT id, (SELECT COUNT(*) FROM likes WHERE likes.user_id = users.id) + 
	       (SELECT COUNT(*) FROM media WHERE media.user_id = users.id) + 
	       (SELECT COUNT(*) FROM messages WHERE messages.from_user_id = users.id) AS total
FROM users 
WHERE id IN (SELECT * FROM (SELECT id FROM users ORDER BY created_at LIMIT 10) AS count_likes)
GROUP BY users.id
ORDER BY total;

--ДЗ урока 7

-- 1. Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине
SELECT users.id, users.name
FROM
  users
JOIN
  orders
ON
  usersu.id = orders.user_id;
 
 -- 2. Выведите список товаров products и разделов catalogs, который соответствует товару.
SELECT products.id,  products.name AS 'product', catalogs.name AS 'catalog'
FROM
  products
LEFT JOIN
  catalogs
ON
  products.catalog_id = catalogs.id;

 


