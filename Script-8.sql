USE vk;

-- 1. Добавить необходимые внешние ключи для всех таблиц базы данных vk
ALTER TABLE profiles
  ADD CONSTRAINT profiles_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT profiles_photo_id_fk
    FOREIGN KEY (photo_id) REFERENCES media(id)
      ON DELETE SET NULL;
     
ALTER TABLE profiles MODIFY photo_id INT(10) UNSIGNED;

ALTER TABLE messages
  ADD CONSTRAINT messages_from_user_id_fk 
    FOREIGN KEY (from_user_id) REFERENCES users(id),
  ADD CONSTRAINT messages_to_user_id_fk 
    FOREIGN KEY (to_user_id) REFERENCES users(id);
   
ALTER TABLE communities
  ADD CONSTRAINT communities_photo_id_fk 
    FOREIGN KEY (photo_id) REFERENCES media(id)
      ON DELETE SET NULL;
     
 ALTER TABLE communities_users
   ADD CONSTRAINT communities_users_user_id_fk 
     FOREIGN KEY (user_id) REFERENCES users(id)
       ON DELETE CASCADE;
     
 ALTER TABLE meetings_users
   ADD CONSTRAINT meetings_users_user_id_fk 
     FOREIGN KEY (user_id) REFERENCES users(id)
       ON DELETE CASCADE,
   ADD CONSTRAINT meetings_meeting_id_fk 
     FOREIGN KEY (meeting_id) REFERENCES meetings(id);
      
 ALTER TABLE likes
   ADD CONSTRAINT likes_user_id_fk 
     FOREIGN KEY (user_id) REFERENCES users(id)
       ON DELETE CASCADE,
   ADD CONSTRAINT likes_target_id_fk 
     FOREIGN KEY (target_id) REFERENCES users(id)
       ON DELETE CASCADE,
   ADD CONSTRAINT likes_target_type_id_fk 
     FOREIGN KEY (target_type_id) REFERENCES target_types(id)
       ON DELETE SET NULL;
      
  ALTER TABLE likes MODIFY target_type_id INT(10) UNSIGNED;
 
  ALTER TABLE friendship
   ADD CONSTRAINT friendship_user_id_fk 
     FOREIGN KEY (user_id) REFERENCES users(id)
       ON DELETE CASCADE,
   ADD CONSTRAINT friendship_friend_id_fk 
     FOREIGN KEY (friend_id) REFERENCES users(id)
       ON DELETE CASCADE,
   ADD CONSTRAINT friendship_status_id_fk 
     FOREIGN KEY (status_id) REFERENCES friendship_statuses(id)
       ON DELETE SET NULL;
      
   ALTER TABLE friendship MODIFY status_id INT(10) UNSIGNED;
  
  ALTER TABLE media
   ADD CONSTRAINT media_user_id_fk 
     FOREIGN KEY (user_id) REFERENCES users(id),
   ADD CONSTRAINT media_media_type_id_fk 
     FOREIGN KEY (media_type_id) REFERENCES media_types(id)
       ON DELETE SET NULL;

  ALTER TABLE media MODIFY media_type_id INT(10) UNSIGNED;
  
 ALTER TABLE posts
   ADD CONSTRAINT posts_user_id_fk 
     FOREIGN KEY (user_id) REFERENCES users(id)
       ON DELETE CASCADE,
   ADD CONSTRAINT posts_media_id_fk 
     FOREIGN KEY (media_id) REFERENCES media(id)
       ON DELETE SET NULL;
 
-- 2.Пусть задан некоторый пользователь.Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.
SELECT from_user_id, COUNT(*) AS total_messages
  FROM messages
    LEFT JOIN friendship
      ON (friendship.friend_id = messages.to_user_id
       OR friendship.user_id = messages.to_user_id)
      AND friendship.status_id = 2
  WHERE to_user_id = 120 
    GROUP BY messages.from_user_id
      ORDER BY total_messages DESC
        LIMIT 1;


-- 3. Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей. 
SELECT SUM(total_likes) AS likes_total FROM (
SELECT users.id, profiles.birthday,  COUNT(*) AS total_likes
  FROM users
    JOIN profiles
      ON users.id = profiles.user_id
    LEFT JOIN likes
      ON users.id = likes.target_id
  GROUP BY users.id
  ORDER BY birthday DESC
  LIMIT 10
 ) AS counted_likes;


-- 4. Определить кто больше поставил лайков (всего) - мужчины или женщины?

SELECT sex, COUNT(*) as likes_count 
FROM likes
  JOIN profiles
    ON profiles.user_id = likes.user_id
GROUP BY sex
ORDER BY likes_count DESC
LIMIT 1;


 -- 5. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети
 -- я взяла выборку из 10 самых раних пользователей и уже смотрела кто из них проявляет меньшую активность       

SELECT users.id, users.created_at, COUNT(*) as count_total
FROM users
  LEFT JOIN likes 
    ON likes.user_id = users.id 
  LEFT JOIN media 
    ON media.user_id = users.id
  LEFT JOIN messages 
    ON messages.from_user_id = users.id
GROUP BY users.id
ORDER BY users.created_at, count_total
LIMIT 10;

