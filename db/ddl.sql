CREATE TABLE `hello_world_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `kb_account_id` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_kb_account_id` (`kb_account_id`)
) ENGINE=InnoDB CHARACTER SET utf8 COLLATE utf8_bin;
