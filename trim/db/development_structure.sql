CREATE TABLE `api_hits` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `method_id` tinyint(3) unsigned NOT NULL,
  `ip_address` varchar(15) NOT NULL,
  `day` varchar(10) NOT NULL,
  `hour` varchar(2) NOT NULL,
  `count` int(11) NOT NULL DEFAULT '0',
  `version` int(10) unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `method_id` (`method_id`,`ip_address`,`day`,`hour`),
  CONSTRAINT `api_hits_ibfk_1` FOREIGN KEY (`method_id`) REFERENCES `api_methods` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `api_hits_keys` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `method_id` tinyint(3) unsigned NOT NULL,
  `api_key_id` int(10) unsigned NOT NULL,
  `day` varchar(10) NOT NULL,
  `hour` varchar(2) NOT NULL,
  `count` int(11) NOT NULL DEFAULT '0',
  `version` int(10) unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `method_id` (`method_id`,`api_key_id`,`day`,`hour`),
  KEY `api_key_id` (`api_key_id`),
  CONSTRAINT `api_hits_keys_ibfk_1` FOREIGN KEY (`method_id`) REFERENCES `api_methods` (`id`),
  CONSTRAINT `api_hits_keys_ibfk_2` FOREIGN KEY (`api_key_id`) REFERENCES `api_keys` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `api_keys` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `website_id` tinyint(3) unsigned NOT NULL,
  `api_key` varchar(48) NOT NULL,
  `name` varchar(32) NOT NULL,
  `url` varchar(32) NOT NULL,
  `email` varchar(32) NOT NULL,
  `bypass` enum('YES','NO') NOT NULL DEFAULT 'NO',
  `status` enum('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `website_id` (`website_id`,`api_key`),
  CONSTRAINT `api_keys_ibfk_1` FOREIGN KEY (`website_id`) REFERENCES `websites` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `api_limits` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `method_id` tinyint(3) unsigned NOT NULL,
  `hour` int(10) unsigned NOT NULL,
  `day` int(10) unsigned NOT NULL,
  `reqkey` enum('YES','NO') NOT NULL DEFAULT 'NO',
  PRIMARY KEY (`id`),
  UNIQUE KEY `method_id` (`method_id`),
  CONSTRAINT `api_limits_ibfk_1` FOREIGN KEY (`method_id`) REFERENCES `api_methods` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `api_methods` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `website_id` tinyint(3) unsigned NOT NULL,
  `code` varchar(32) NOT NULL,
  `name` varchar(32) NOT NULL,
  `restricted` enum('YES','NO') NOT NULL DEFAULT 'NO',
  `nambuonly` enum('YES','NO') NOT NULL DEFAULT 'NO',
  PRIMARY KEY (`id`),
  UNIQUE KEY `website_id` (`website_id`,`code`),
  CONSTRAINT `api_methods_ibfk_1` FOREIGN KEY (`website_id`) REFERENCES `websites` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `api_overrides` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `api_key_id` int(10) unsigned NOT NULL,
  `method_id` tinyint(3) unsigned NOT NULL,
  `hour` int(10) unsigned NOT NULL,
  `day` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `api_key_id` (`api_key_id`,`method_id`),
  KEY `method_id` (`method_id`),
  CONSTRAINT `api_overrides_ibfk_1` FOREIGN KEY (`api_key_id`) REFERENCES `api_keys` (`id`) ON DELETE CASCADE,
  CONSTRAINT `api_overrides_ibfk_2` FOREIGN KEY (`method_id`) REFERENCES `api_methods` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `cities` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `country_id` tinyint(3) unsigned NOT NULL,
  `region_id` int(10) unsigned DEFAULT NULL,
  `name` varchar(128) NOT NULL,
  `display` varchar(128) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `name` (`name`),
  KEY `country_id` (`country_id`),
  KEY `region_id` (`region_id`),
  CONSTRAINT `cities_ibfk_1` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`),
  CONSTRAINT `cities_ibfk_2` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `countries` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(2) NOT NULL,
  `name` varchar(128) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=255 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `emails` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `website_id` tinyint(3) unsigned NOT NULL,
  `code` varchar(24) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `website_id` (`website_id`),
  CONSTRAINT `emails_ibfk_1` FOREIGN KEY (`website_id`) REFERENCES `websites` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `ip_cities` (
  `ip_from` int(10) unsigned zerofill NOT NULL DEFAULT '0000000000',
  `ip_to` int(10) unsigned zerofill NOT NULL DEFAULT '0000000000',
  `country_code` char(2) NOT NULL,
  `country_name` varchar(64) NOT NULL,
  `region` varchar(128) NOT NULL,
  `city` varchar(128) NOT NULL,
  PRIMARY KEY (`ip_from`,`ip_to`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `ip_countries` (
  `ip_from` int(10) unsigned NOT NULL,
  `ip_to` int(10) unsigned NOT NULL,
  `country_code` varchar(2) NOT NULL,
  `country_name` varchar(64) NOT NULL,
  KEY `index_ipfrom` (`ip_from`),
  KEY `index_ipto` (`ip_to`),
  KEY `ip_from` (`ip_from`,`ip_to`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `languages` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(2) NOT NULL,
  `name_en` varchar(24) NOT NULL,
  `name_nt` varchar(24) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `network_o_auths` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `website_id` tinyint(3) unsigned NOT NULL,
  `network_id` tinyint(3) unsigned NOT NULL,
  `username` varchar(48) NOT NULL DEFAULT 'UNKNOWN',
  `user_id` int(10) unsigned NOT NULL DEFAULT '0',
  `req_token` varchar(64) NOT NULL,
  `acs_token` varchar(64) NOT NULL DEFAULT 'NONE',
  `acs_secret` varchar(64) NOT NULL DEFAULT 'NONE',
  `status` enum('PENDING','DONE') NOT NULL DEFAULT 'PENDING',
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `req_token` (`req_token`),
  KEY `website_id` (`website_id`),
  KEY `network_id` (`network_id`),
  CONSTRAINT `network_o_auths_ibfk_1` FOREIGN KEY (`website_id`) REFERENCES `websites` (`id`),
  CONSTRAINT `network_o_auths_ibfk_2` FOREIGN KEY (`network_id`) REFERENCES `networks` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `networks` (
  `id` tinyint(3) unsigned NOT NULL,
  `code` varchar(12) NOT NULL,
  `name` varchar(32) NOT NULL,
  `url` varchar(32) NOT NULL,
  `domain` varchar(48) NOT NULL,
  `api` varchar(32) NOT NULL,
  `ordernum` tinyint(4) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `url` (`url`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `private_clicks` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `purl_id` int(10) unsigned NOT NULL,
  `country_id` tinyint(3) unsigned NOT NULL DEFAULT '255',
  `agent_id` int(10) unsigned NOT NULL DEFAULT '1',
  `ip_address` varchar(15) NOT NULL,
  `referer` varchar(128) DEFAULT NULL,
  `summarized` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `purl_id` (`purl_id`),
  KEY `country_id` (`country_id`),
  KEY `agent_id` (`agent_id`),
  CONSTRAINT `private_clicks_ibfk_1` FOREIGN KEY (`purl_id`) REFERENCES `private_urls` (`id`) ON DELETE CASCADE,
  CONSTRAINT `private_clicks_ibfk_2` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`),
  CONSTRAINT `private_clicks_ibfk_3` FOREIGN KEY (`agent_id`) REFERENCES `user_agents` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `private_domains` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `domain` varchar(48) NOT NULL,
  `sequence` int(10) unsigned NOT NULL DEFAULT '25000',
  `version` int(10) unsigned NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `domain` (`domain`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `private_domains_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `private_urls` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `url_id` int(10) unsigned NOT NULL,
  `domain_id` int(10) unsigned NOT NULL,
  `surl` varchar(48) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
  `title` varchar(48) DEFAULT NULL,
  `custom` varchar(48) DEFAULT NULL,
  `privacy` varchar(48) DEFAULT NULL,
  `searchtags` varchar(255) DEFAULT NULL,
  `description` varchar(512) DEFAULT NULL,
  `reference` varchar(30) NOT NULL,
  `clicks` int(10) unsigned NOT NULL DEFAULT '0',
  `version` int(10) unsigned NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `reference` (`reference`),
  KEY `surl` (`surl`),
  KEY `custom` (`custom`),
  KEY `privacy` (`privacy`),
  KEY `created_at` (`created_at`),
  KEY `url_id` (`url_id`),
  KEY `domain_id` (`domain_id`),
  CONSTRAINT `private_urls_ibfk_1` FOREIGN KEY (`url_id`) REFERENCES `url_destinations` (`id`) ON DELETE CASCADE,
  CONSTRAINT `private_urls_ibfk_2` FOREIGN KEY (`domain_id`) REFERENCES `private_domains` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `referers` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `url` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  UNIQUE KEY `url` (`url`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `regions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `country_id` tinyint(3) unsigned NOT NULL,
  `name` varchar(128) NOT NULL,
  `display` varchar(128) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `name` (`name`),
  KEY `country_id` (`country_id`),
  CONSTRAINT `regions_ibfk_1` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `session_o_auths` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `oauth_id` int(10) unsigned NOT NULL,
  `session_id` varchar(128) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `oauth_id` (`oauth_id`,`session_id`),
  KEY `session_id` (`session_id`),
  CONSTRAINT `session_o_auths_ibfk_1` FOREIGN KEY (`oauth_id`) REFERENCES `network_o_auths` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `sessions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) DEFAULT NULL,
  `data` text,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `statistics_signups` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `website_id` tinyint(3) unsigned NOT NULL,
  `tdate` date NOT NULL,
  `total` int(11) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `website_id` (`website_id`),
  CONSTRAINT `statistics_signups_ibfk_1` FOREIGN KEY (`website_id`) REFERENCES `websites` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `statistics_tweets` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `website_id` tinyint(3) unsigned NOT NULL,
  `tdate` date NOT NULL,
  `total` int(11) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `website_id` (`website_id`),
  CONSTRAINT `statistics_tweets_ibfk_1` FOREIGN KEY (`website_id`) REFERENCES `websites` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `statistics_urls` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `website_id` tinyint(3) unsigned NOT NULL,
  `tdate` date NOT NULL,
  `total` int(11) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `website_id` (`website_id`),
  CONSTRAINT `statistics_urls_ibfk_1` FOREIGN KEY (`website_id`) REFERENCES `websites` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `tlds` (
  `id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `tld` varchar(32) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tld` (`tld`)
) ENGINE=InnoDB AUTO_INCREMENT=1810 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `trim_actions` (
  `id` tinyint(3) unsigned NOT NULL,
  `action` varchar(18) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `action` (`action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `trim_activity` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `action_id` tinyint(3) unsigned NOT NULL,
  `country_id` tinyint(3) unsigned NOT NULL DEFAULT '255',
  `session_id` varchar(128) NOT NULL,
  `ip_address` varchar(15) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  KEY `session_id` (`session_id`),
  KEY `ip_address` (`ip_address`),
  KEY `action_id` (`action_id`,`created_at`),
  KEY `country_id` (`country_id`),
  CONSTRAINT `trim_activity_ibfk_1` FOREIGN KEY (`action_id`) REFERENCES `trim_actions` (`id`),
  CONSTRAINT `trim_activity_ibfk_2` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `trim_claimants` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `oauth_id` int(10) unsigned NOT NULL,
  `status_id` int(10) unsigned NOT NULL DEFAULT '0',
  `checked_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`,`oauth_id`),
  KEY `checked_at` (`checked_at`),
  KEY `oauth_id` (`oauth_id`),
  CONSTRAINT `trim_claimants_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `trim_claimants_ibfk_2` FOREIGN KEY (`oauth_id`) REFERENCES `network_o_auths` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `trim_clicks` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `trim_url_id` int(10) unsigned NOT NULL,
  `country_id` tinyint(3) unsigned NOT NULL DEFAULT '255',
  `region_id` int(10) unsigned NOT NULL DEFAULT '1',
  `city_id` int(10) unsigned NOT NULL DEFAULT '1',
  `agent_id` int(10) unsigned NOT NULL DEFAULT '1',
  `ip_address` varchar(15) NOT NULL,
  `referer` varchar(128) DEFAULT NULL,
  `version` int(10) unsigned NOT NULL DEFAULT '0',
  `summarized` int(10) unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `summarized` (`summarized`),
  KEY `trim_url_id` (`trim_url_id`),
  KEY `country_id` (`country_id`),
  KEY `region_id` (`region_id`),
  CONSTRAINT `trim_clicks_ibfk_1` FOREIGN KEY (`trim_url_id`) REFERENCES `trim_urls` (`id`) ON DELETE CASCADE,
  CONSTRAINT `trim_clicks_ibfk_2` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`),
  CONSTRAINT `trim_clicks_ibfk_3` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `trim_group_urls` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `group_id` int(10) unsigned NOT NULL,
  `trim_url_id` int(10) unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `group_id` (`group_id`),
  KEY `trim_url_id` (`trim_url_id`),
  CONSTRAINT `trim_group_urls_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `trim_groups` (`id`) ON DELETE CASCADE,
  CONSTRAINT `trim_group_urls_ibfk_2` FOREIGN KEY (`trim_url_id`) REFERENCES `trim_urls` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `trim_groups` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `name` varchar(32) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `trim_groups_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `trim_namespace` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `surl` varchar(12) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  UNIQUE KEY `surl` (`surl`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `trim_preferences` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `trimtweet` enum('YES','NO') NOT NULL DEFAULT 'YES',
  `savepwds` enum('YES','NO') NOT NULL DEFAULT 'YES',
  `autosubmit` enum('YES','NO') NOT NULL DEFAULT 'YES',
  `newforstats` enum('YES','NO') NOT NULL DEFAULT 'YES',
  `comments` enum('YES','NO') NOT NULL DEFAULT 'YES',
  `copypaste` enum('YES','NO') NOT NULL DEFAULT 'YES',
  `return_id` tinyint(3) unsigned NOT NULL DEFAULT '1',
  `urlsort` tinyint(3) unsigned NOT NULL DEFAULT '2',
  `urlsppage` tinyint(3) unsigned NOT NULL DEFAULT '5',
  `picsort` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `picsppage` tinyint(3) unsigned NOT NULL DEFAULT '8',
  `charts` enum('FLASH','PCHART') NOT NULL DEFAULT 'FLASH',
  `statspublic` enum('YES','NO') NOT NULL DEFAULT 'NO',
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `return_id` (`return_id`),
  CONSTRAINT `trim_preferences_ibfk_1` FOREIGN KEY (`return_id`) REFERENCES `url_returns` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `trim_preferences_anonymous` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `session_id` varchar(128) NOT NULL,
  `prefs_id` int(10) unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `session_id` (`session_id`,`prefs_id`),
  KEY `session_id_2` (`session_id`),
  KEY `prefs_id` (`prefs_id`),
  CONSTRAINT `trim_preferences_anonymous_ibfk_1` FOREIGN KEY (`prefs_id`) REFERENCES `trim_preferences` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `trim_preferences_users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `prefs_id` int(10) unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`,`prefs_id`),
  KEY `user_id_2` (`user_id`),
  KEY `prefs_id` (`prefs_id`),
  CONSTRAINT `trim_preferences_users_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `trim_preferences_users_ibfk_2` FOREIGN KEY (`prefs_id`) REFERENCES `trim_preferences` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `trim_session_urls` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `session_id` varchar(128) NOT NULL,
  `trim_url_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `trim_url_id` (`trim_url_id`),
  CONSTRAINT `trim_session_urls_ibfk_1` FOREIGN KEY (`trim_url_id`) REFERENCES `trim_urls` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `trim_summaries_agents` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `trim_url_id` int(10) unsigned NOT NULL,
  `agent_id` int(10) unsigned NOT NULL,
  `total` int(10) unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `trim_url_id` (`trim_url_id`),
  KEY `agent_id` (`agent_id`),
  CONSTRAINT `trim_summaries_agents_ibfk_1` FOREIGN KEY (`trim_url_id`) REFERENCES `trim_urls` (`id`) ON DELETE CASCADE,
  CONSTRAINT `trim_summaries_agents_ibfk_2` FOREIGN KEY (`agent_id`) REFERENCES `user_agents` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `trim_summaries_cities` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `trim_url_id` int(10) unsigned NOT NULL,
  `country_id` tinyint(3) unsigned NOT NULL,
  `city_id` int(10) unsigned NOT NULL,
  `total` int(10) unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `trim_url_id` (`trim_url_id`),
  KEY `country_id` (`country_id`),
  KEY `city_id` (`city_id`),
  CONSTRAINT `trim_summaries_cities_ibfk_1` FOREIGN KEY (`trim_url_id`) REFERENCES `trim_urls` (`id`) ON DELETE CASCADE,
  CONSTRAINT `trim_summaries_cities_ibfk_2` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`),
  CONSTRAINT `trim_summaries_cities_ibfk_3` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `trim_summaries_countries` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `trim_url_id` int(10) unsigned NOT NULL,
  `country_id` tinyint(3) unsigned NOT NULL,
  `total` int(10) unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `trim_url_id` (`trim_url_id`),
  KEY `country_id` (`country_id`),
  CONSTRAINT `trim_summaries_countries_ibfk_1` FOREIGN KEY (`trim_url_id`) REFERENCES `trim_urls` (`id`) ON DELETE CASCADE,
  CONSTRAINT `trim_summaries_countries_ibfk_2` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `trim_summaries_referers` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `trim_url_id` int(10) unsigned NOT NULL,
  `referer_id` int(10) unsigned NOT NULL,
  `total` int(10) unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `trim_url_id` (`trim_url_id`),
  KEY `referer_id` (`referer_id`),
  CONSTRAINT `trim_summaries_referers_ibfk_1` FOREIGN KEY (`trim_url_id`) REFERENCES `trim_urls` (`id`) ON DELETE CASCADE,
  CONSTRAINT `trim_summaries_referers_ibfk_2` FOREIGN KEY (`referer_id`) REFERENCES `referers` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `trim_summaries_regions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `trim_url_id` int(10) unsigned NOT NULL,
  `country_id` tinyint(3) unsigned NOT NULL,
  `region_id` int(10) unsigned NOT NULL,
  `total` int(10) unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `trim_url_id` (`trim_url_id`),
  KEY `country_id` (`country_id`),
  KEY `region_id` (`region_id`),
  CONSTRAINT `trim_summaries_regions_ibfk_1` FOREIGN KEY (`trim_url_id`) REFERENCES `trim_urls` (`id`) ON DELETE CASCADE,
  CONSTRAINT `trim_summaries_regions_ibfk_2` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`),
  CONSTRAINT `trim_summaries_regions_ibfk_3` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `trim_tweets` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `oauth_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `trim_url_id` int(10) unsigned NOT NULL,
  `tweet` varchar(180) NOT NULL,
  `tweet_id` int(10) unsigned NOT NULL,
  `remote_id` int(10) unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  KEY `created_at` (`created_at`),
  KEY `oauth_id` (`oauth_id`),
  KEY `user_id` (`user_id`),
  KEY `trim_url_id` (`trim_url_id`),
  CONSTRAINT `trim_tweets_ibfk_1` FOREIGN KEY (`oauth_id`) REFERENCES `network_o_auths` (`id`),
  CONSTRAINT `trim_tweets_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `trim_tweets_ibfk_3` FOREIGN KEY (`trim_url_id`) REFERENCES `trim_urls` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `trim_urls` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `shortened_id` int(10) unsigned NOT NULL,
  `return_id` tinyint(3) unsigned NOT NULL,
  `reference` varchar(30) NOT NULL,
  `title` varchar(48) DEFAULT NULL,
  `custom` varchar(48) DEFAULT NULL,
  `privacy` varchar(48) DEFAULT NULL,
  `searchtags` varchar(255) DEFAULT NULL,
  `description` varchar(512) DEFAULT NULL,
  `deletion` enum('YES','NO') NOT NULL DEFAULT 'NO',
  `clicks` int(10) unsigned NOT NULL DEFAULT '0',
  `version` int(10) unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `reference` (`reference`),
  KEY `custom` (`custom`),
  KEY `privacy` (`privacy`),
  KEY `deletion` (`deletion`),
  KEY `created_at` (`created_at`),
  KEY `shortened_id` (`shortened_id`),
  KEY `return_id` (`return_id`),
  CONSTRAINT `trim_urls_ibfk_1` FOREIGN KEY (`shortened_id`) REFERENCES `url_shortenings` (`id`) ON DELETE CASCADE,
  CONSTRAINT `trim_urls_ibfk_2` FOREIGN KEY (`return_id`) REFERENCES `url_returns` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `trim_urls_sequence` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `shortened_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `shortened_id` (`shortened_id`),
  CONSTRAINT `trim_urls_sequence_ibfk_1` FOREIGN KEY (`shortened_id`) REFERENCES `url_shortenings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `trim_user_urls` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `trim_url_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `trim_url_id` (`trim_url_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `trim_user_urls_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `trim_user_urls_ibfk_2` FOREIGN KEY (`trim_url_id`) REFERENCES `trim_urls` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `url_destinations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `url` varchar(2000) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  KEY `url` (`url`(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `url_origins` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `origin` varchar(12) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `origin` (`origin`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `url_returns` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(18) NOT NULL,
  `name` varchar(48) NOT NULL,
  `display` enum('YES','NO') NOT NULL DEFAULT 'NO',
  `ordernum` tinyint(4) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `display` (`display`),
  KEY `ordernum` (`ordernum`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `url_shorteners` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `domain` varchar(32) NOT NULL,
  `nbprocess` enum('YES','NO') NOT NULL DEFAULT 'YES',
  `dmprocess` enum('YES','NO') NOT NULL DEFAULT 'YES',
  PRIMARY KEY (`id`),
  UNIQUE KEY `domain` (`domain`)
) ENGINE=InnoDB AUTO_INCREMENT=118 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `url_shortenings` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `shortener_id` tinyint(3) unsigned NOT NULL,
  `origin_id` tinyint(3) unsigned NOT NULL,
  `url_id` int(10) unsigned NOT NULL,
  `surl` varchar(48) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
  `identifier` varchar(128) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  KEY `surl` (`surl`),
  KEY `shortener_id` (`shortener_id`),
  KEY `origin_id` (`origin_id`),
  KEY `url_id` (`url_id`),
  CONSTRAINT `url_shortenings_ibfk_1` FOREIGN KEY (`shortener_id`) REFERENCES `url_shorteners` (`id`),
  CONSTRAINT `url_shortenings_ibfk_2` FOREIGN KEY (`origin_id`) REFERENCES `url_origins` (`id`),
  CONSTRAINT `url_shortenings_ibfk_3` FOREIGN KEY (`url_id`) REFERENCES `url_destinations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `url_spam_domains` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `domain` varchar(128) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `domain` (`domain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `user_agent_filters` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `platform_id` tinyint(3) unsigned NOT NULL,
  `browser_id` tinyint(3) unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `platform_id` (`platform_id`),
  KEY `browser_id` (`browser_id`),
  CONSTRAINT `user_agent_filters_ibfk_1` FOREIGN KEY (`platform_id`) REFERENCES `user_platforms` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_agent_filters_ibfk_2` FOREIGN KEY (`browser_id`) REFERENCES `user_browsers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `user_agent_terms` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `filter_id` int(10) unsigned NOT NULL,
  `term` varchar(24) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `filter_id` (`filter_id`),
  CONSTRAINT `user_agent_terms_ibfk_1` FOREIGN KEY (`filter_id`) REFERENCES `user_agent_filters` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `user_agents` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `platform_id` tinyint(3) unsigned NOT NULL DEFAULT '1',
  `browser_id` tinyint(3) unsigned NOT NULL DEFAULT '1',
  `details` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `details` (`details`),
  KEY `platform_id` (`platform_id`),
  KEY `browser_id` (`browser_id`),
  CONSTRAINT `user_agents_ibfk_1` FOREIGN KEY (`platform_id`) REFERENCES `user_platforms` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_agents_ibfk_2` FOREIGN KEY (`browser_id`) REFERENCES `user_browsers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `user_browsers` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(18) NOT NULL,
  `name` varchar(32) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `user_disqus` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `website_id` tinyint(3) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `forum` varchar(48) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `website_id` (`website_id`,`forum`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `user_disqus_ibfk_1` FOREIGN KEY (`website_id`) REFERENCES `websites` (`id`),
  CONSTRAINT `user_disqus_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `user_logins` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `ip_address` varchar(15) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `user_logins_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `user_o_auths` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `oauth_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`,`oauth_id`),
  KEY `oauth_id` (`oauth_id`),
  CONSTRAINT `user_o_auths_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_o_auths_ibfk_2` FOREIGN KEY (`oauth_id`) REFERENCES `network_o_auths` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `user_platforms` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(18) NOT NULL,
  `name` varchar(32) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `user_resets` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `code` varchar(32) NOT NULL,
  `status` enum('PENDING','USED') NOT NULL DEFAULT 'PENDING',
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `created_at` (`created_at`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `user_resets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `website_id` tinyint(3) unsigned NOT NULL,
  `origin_id` tinyint(3) unsigned NOT NULL,
  `language_id` tinyint(3) unsigned NOT NULL,
  `name` varchar(48) NOT NULL,
  `email` varchar(96) NOT NULL,
  `login` varchar(48) NOT NULL,
  `salt` varchar(64) NOT NULL,
  `password` varchar(128) NOT NULL,
  `time_zone` varchar(48) NOT NULL DEFAULT 'Eastern Time (US & Canada)',
  `country_id` tinyint(3) unsigned NOT NULL DEFAULT '255',
  `last_ip` varchar(15) NOT NULL,
  `source` enum('MANUAL','AUTO','API') NOT NULL DEFAULT 'MANUAL',
  `last_seen` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `website_id` (`website_id`,`login`),
  KEY `origin_id` (`origin_id`),
  KEY `language_id` (`language_id`),
  KEY `country_id` (`country_id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`website_id`) REFERENCES `websites` (`id`),
  CONSTRAINT `users_ibfk_2` FOREIGN KEY (`origin_id`) REFERENCES `websites` (`id`),
  CONSTRAINT `users_ibfk_3` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`),
  CONSTRAINT `users_ibfk_4` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `websites` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL,
  `domain` varchar(24) NOT NULL,
  `validations` enum('YES','NO') NOT NULL DEFAULT 'YES',
  PRIMARY KEY (`id`),
  UNIQUE KEY `domain` (`domain`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

INSERT INTO schema_migrations (version) VALUES ('1');