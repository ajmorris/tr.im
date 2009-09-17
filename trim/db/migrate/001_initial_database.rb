##
# Copyright (c) The Nambu Network Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
# is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
# IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
##

class InitialDatabase < ActiveRecord::Migration
  def self.up
    ## The so-called STATIC Schema
    execute <<-SQL
      CREATE TABLE countries
      (
        id            TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
        code          VARCHAR(2) NOT NULL,
        name          VARCHAR(128) NOT NULL,
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (code)
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
    
    execute <<-SQL
      CREATE TABLE regions
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        country_id    TINYINT UNSIGNED NOT NULL,
        name          VARCHAR(128) NOT NULL,
        display       VARCHAR(128) NOT NULL,
          PRIMARY KEY (id),
          INDEX (name),
          CONSTRAINT FOREIGN KEY (country_id) REFERENCES countries (id) ON DELETE RESTRICT
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
    
    execute <<-SQL
      CREATE TABLE cities
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        country_id    TINYINT UNSIGNED NOT NULL,
        region_id     INTEGER UNSIGNED,
        name          VARCHAR(128) NOT NULL,
        display       VARCHAR(128) NOT NULL,
          PRIMARY KEY (id),
          INDEX (name),
          CONSTRAINT FOREIGN KEY (country_id) REFERENCES countries (id) ON DELETE RESTRICT,
          CONSTRAINT FOREIGN KEY (region_id) REFERENCES regions (id) ON DELETE RESTRICT
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE tlds
      (
        id            SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
        tld           VARCHAR(32) NOT NULL,
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (tld)
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
    
    execute <<-SQL
      CREATE TABLE languages
      (
        id            TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
        code          VARCHAR(2) NOT NULL,
        name_en       VARCHAR(24) NOT NULL,
        name_nt       VARCHAR(24) NOT NULL,
          PRIMARY KEY (id)
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE websites
      (
        id             TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
        name           VARCHAR(32) NOT NULL,
        domain         VARCHAR(24) NOT NULL,
        validations    ENUM('YES','NO') NOT NULL DEFAULT 'YES',
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (domain)
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE networks
      (
        id            TINYINT UNSIGNED NOT NULL,
        code          VARCHAR(12) NOT NULL,
        name          VARCHAR(32) NOT NULL,
        url           VARCHAR(32) NOT NULL,
        domain        VARCHAR(48) NOT NULL,
        api           VARCHAR(32) NOT NULL,
        ordernum      TINYINT NOT NULL,
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (name),
          CONSTRAINT UNIQUE (url)
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
    
    execute <<-SQL
      CREATE TABLE emails
      (
        id            TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
        website_id    TINYINT UNSIGNED NOT NULL,
        code          VARCHAR(24) NOT NULL,
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (code),
          CONSTRAINT FOREIGN KEY (website_id) REFERENCES websites (id) ON DELETE RESTRICT
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
    
    execute <<-SQL
      CREATE TABLE ip_countries (
        ip_from       INTEGER UNSIGNED NOT NULL,
        ip_to         INTEGER UNSIGNED NOT NULL,
        country_code  VARCHAR(2) NOT NULL,
        country_name  VARCHAR(64) NOT NULL,
          KEY index_ipfrom (ip_from),
          KEY index_ipto (ip_to),
          INDEX (ip_from, ip_to)
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE ip_cities (
        ip_from       INTEGER UNSIGNED ZEROFILL NOT NULL DEFAULT '0000000000',
        ip_to         INTEGER UNSIGNED ZEROFILL NOT NULL DEFAULT '0000000000',
        country_code  CHAR(2) NOT NULL,
        country_name  VARCHAR(64) NOT NULL,
        region        VARCHAR(128) NOT NULL,
        city          VARCHAR(128) NOT NULL, 
          PRIMARY KEY(ip_from, ip_to)
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
    

    ## Users Tables
    execute <<-SQL
      CREATE TABLE users
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        website_id    TINYINT UNSIGNED NOT NULL,
        origin_id     TINYINT UNSIGNED NOT NULL,
        language_id   TINYINT UNSIGNED NOT NULL,
        name          VARCHAR(48) NOT NULL,
        email         VARCHAR(96) NOT NULL,
        login         VARCHAR(48) NOT NULL,
        salt          VARCHAR(64) NOT NULL,
        password      VARCHAR(128) NOT NULL,
        time_zone     VARCHAR(48) NOT NULL DEFAULT 'Eastern Time (US & Canada)',
        country_id    TINYINT UNSIGNED NOT NULL DEFAULT 255,
        last_ip       VARCHAR(15) NOT NULL,
        source        ENUM('MANUAL','AUTO','API') NOT NULL DEFAULT 'MANUAL',
        last_seen     TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (website_id, login),
          CONSTRAINT FOREIGN KEY (website_id) REFERENCES websites (id) ON DELETE RESTRICT,
          CONSTRAINT FOREIGN KEY (origin_id) REFERENCES websites (id) ON DELETE RESTRICT,
          CONSTRAINT FOREIGN KEY (language_id) REFERENCES languages (id) ON DELETE RESTRICT,
          CONSTRAINT FOREIGN KEY (country_id) REFERENCES countries (id) ON DELETE RESTRICT
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE user_logins
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        user_id       INTEGER UNSIGNED NOT NULL,
        ip_address    VARCHAR(15) NOT NULL,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          CONSTRAINT FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
    
    execute <<-SQL      
      CREATE TABLE user_disqus
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        website_id    TINYINT UNSIGNED NOT NULL,
        user_id       INTEGER UNSIGNED NOT NULL,
        forum         VARCHAR(48) NOT NULL,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (website_id, forum),
          CONSTRAINT FOREIGN KEY (website_id) REFERENCES websites (id) ON DELETE RESTRICT,
          CONSTRAINT FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE user_resets
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        user_id       INTEGER UNSIGNED NOT NULL,
        code          VARCHAR(32) NOT NULL,
        status        ENUM('PENDING','USED') NOT NULL DEFAULT 'PENDING',
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          INDEX (created_at),
          CONSTRAINT UNIQUE (code),
          CONSTRAINT FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    
    ## OAuth Tables
    execute <<-SQL
      CREATE TABLE network_o_auths
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        website_id    TINYINT UNSIGNED NOT NULL,
        network_id    TINYINT UNSIGNED NOT NULL,
        username      VARCHAR(48) NOT NULL DEFAULT 'UNKNOWN',
        user_id       INTEGER UNSIGNED NOT NULL DEFAULT 0,
        req_token     VARCHAR(64) NOT NULL,
        acs_token     VARCHAR(64) NOT NULL DEFAULT 'NONE',
        acs_secret    VARCHAR(64) NOT NULL DEFAULT 'NONE',
        status        ENUM('PENDING','DONE') NOT NULL DEFAULT 'PENDING',
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (req_token),
          CONSTRAINT FOREIGN KEY (website_id) REFERENCES websites (id) ON DELETE RESTRICT,
          CONSTRAINT FOREIGN KEY (network_id) REFERENCES networks (id) ON DELETE RESTRICT
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE user_o_auths
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        user_id       INTEGER UNSIGNED NOT NULL,
        oauth_id      INTEGER UNSIGNED NOT NULL,
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (user_id, oauth_id),
          CONSTRAINT FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
          CONSTRAINT FOREIGN KEY (oauth_id) REFERENCES network_o_auths (id) ON DELETE CASCADE
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE session_o_auths
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        oauth_id      INTEGER UNSIGNED NOT NULL,
        session_id     VARCHAR(128) NOT NULL,
          PRIMARY KEY (id),
          INDEX (session_id),
          CONSTRAINT UNIQUE (oauth_id, session_id),
          CONSTRAINT FOREIGN KEY (oauth_id) REFERENCES network_o_auths (id) ON DELETE CASCADE
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
    
    
    ## Referers and Agents
    execute <<-SQL
      CREATE TABLE referers
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        url           VARCHAR(255) NOT NULL,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (url)
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
    
    execute <<-SQL      
      CREATE TABLE user_platforms
      (
        id            TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
        code          VARCHAR(18) NOT NULL,
        name          VARCHAR(32) NOT NULL,
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (name)
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL 
      CREATE TABLE user_browsers
      (
        id            TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
        code          VARCHAR(18) NOT NULL,
        name          VARCHAR(32) NOT NULL,
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (name)
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE user_agents
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        platform_id   TINYINT UNSIGNED NOT NULL DEFAULT 1,
        browser_id    TINYINT UNSIGNED NOT NULL DEFAULT 1,
        details       VARCHAR(255) NOT NULL,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (details),
          CONSTRAINT FOREIGN KEY (platform_id) REFERENCES user_platforms (id) ON DELETE CASCADE,
          CONSTRAINT FOREIGN KEY (browser_id) REFERENCES user_browsers (id) ON DELETE CASCADE
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
    
    execute <<-SQL
      CREATE TABLE user_agent_filters
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        platform_id   TINYINT UNSIGNED NOT NULL,
        browser_id    TINYINT UNSIGNED NOT NULL,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          CONSTRAINT FOREIGN KEY (platform_id) REFERENCES user_platforms (id) ON DELETE CASCADE,
          CONSTRAINT FOREIGN KEY (browser_id) REFERENCES user_browsers (id) ON DELETE CASCADE
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
    
    execute <<-SQL
      CREATE TABLE user_agent_terms
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        filter_id      INTEGER UNSIGNED NOT NULL,
        term          VARCHAR(24) NOT NULL,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          CONSTRAINT FOREIGN KEY (filter_id) REFERENCES user_agent_filters (id) ON DELETE CASCADE
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL


    ## API Tables
    execute <<-SQL
      CREATE TABLE api_methods
      (
        id             TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
        website_id     TINYINT UNSIGNED NOT NULL,
        code           VARCHAR(32) NOT NULL,
        name           VARCHAR(32) NOT NULL,
        restricted     ENUM('YES','NO') NOT NULL DEFAULT 'NO',
        nambuonly      ENUM('YES','NO') NOT NULL DEFAULT 'NO',
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (website_id, code),
          CONSTRAINT FOREIGN KEY (website_id) REFERENCES websites (id) ON DELETE RESTRICT
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
    
    execute <<-SQL
      CREATE TABLE api_limits
      (
        id             TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
        method_id      TINYINT UNSIGNED NOT NULL,
        hour           INTEGER UNSIGNED NOT NULL,
        day            INTEGER UNSIGNED NOT NULL,
        reqkey         ENUM('YES','NO') DEFAULT 'NO' NOT NULL,
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (method_id),
          CONSTRAINT FOREIGN KEY (method_id) REFERENCES api_methods (id) ON DELETE CASCADE
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
    
    execute <<-SQL
      CREATE TABLE api_keys
      (
        id             INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        website_id     TINYINT UNSIGNED NOT NULL,
        api_key        VARCHAR(48) NOT NULL,
        name           VARCHAR(32) NOT NULL,
        url            VARCHAR(32) NOT NULL,
        email          VARCHAR(32) NOT NULL,
        bypass         ENUM('YES','NO') NOT NULL DEFAULT 'NO',
        status         ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
        created_at     TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at     TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (website_id, api_key),
          CONSTRAINT FOREIGN KEY (website_id) REFERENCES websites (id) ON DELETE RESTRICT
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
      
    execute <<-SQL
      CREATE TABLE api_overrides
      (
        id             TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
        api_key_id     INTEGER UNSIGNED NOT NULL,
        method_id      TINYINT UNSIGNED NOT NULL,
        hour           INTEGER UNSIGNED NOT NULL,
        day            INTEGER UNSIGNED NOT NULL,
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (api_key_id, method_id),
          CONSTRAINT FOREIGN KEY (api_key_id) REFERENCES api_keys (id) ON DELETE CASCADE,
          CONSTRAINT FOREIGN KEY (method_id) REFERENCES api_methods (id) ON DELETE CASCADE
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
    
    execute <<-SQL
      CREATE TABLE api_hits
      (
        id             INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        method_id      TINYINT UNSIGNED NOT NULL,
        ip_address     VARCHAR(15) NOT NULL,
        day            VARCHAR(10) NOT NULL,
        hour           VARCHAR(2) NOT NULL,
        count          INTEGER NOT NULL DEFAULT 0,
        version        INTEGER UNSIGNED NOT NULL DEFAULT 0,
        created_at     TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at     TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (method_id, ip_address, day, hour),
          CONSTRAINT FOREIGN KEY (method_id) REFERENCES api_methods (id) ON DELETE RESTRICT
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
      
    execute <<-SQL
      CREATE TABLE api_hits_keys
      (
        id             INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        method_id      TINYINT UNSIGNED NOT NULL,
        api_key_id     INTEGER UNSIGNED NOT NULL,
        day            VARCHAR(10) NOT NULL,
        hour           VARCHAR(2) NOT NULL,
        count          INTEGER NOT NULL DEFAULT 0,
        version        INTEGER UNSIGNED NOT NULL DEFAULT 0,
        created_at     TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at     TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (method_id, api_key_id, day, hour),
          CONSTRAINT FOREIGN KEY (method_id) REFERENCES api_methods (id) ON DELETE RESTRICT,
          CONSTRAINT FOREIGN KEY (api_key_id) REFERENCES api_keys (id) ON DELETE RESTRICT
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    
    ## TR.IM TABLES
    execute <<-SQL
      CREATE TABLE url_shorteners
      (
        id            TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
        domain        VARCHAR(32) NOT NULL,
        nbprocess     ENUM('YES','NO') NOT NULL DEFAULT 'YES',
        dmprocess     ENUM('YES','NO') NOT NULL DEFAULT 'YES',
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (domain)
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE url_origins
      (
        id            TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
        origin        VARCHAR(12) NOT NULL,
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (origin)
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE url_returns
      (
        id            TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
        code          VARCHAR(18) NOT NULL,
        name          VARCHAR(48) NOT NULL,
        display       ENUM('YES','NO') NOT NULL DEFAULT 'NO',
        ordernum      TINYINT NOT NULL,
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (code),
          INDEX (display),
          INDEX (ordernum)
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
    
    execute <<-SQL      
      CREATE TABLE url_spam_domains
      (
        id            TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
        domain        VARCHAR(128) NOT NULL,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (domain)
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
      
    execute <<-SQL
      CREATE TABLE url_destinations
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        url           VARCHAR(2000) NOT NULL,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
          PRIMARY KEY (id),
          INDEX (url)
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE url_shortenings
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        shortener_id  TINYINT UNSIGNED NOT NULL,
        origin_id     TINYINT UNSIGNED NOT NULL,
        url_id        INTEGER UNSIGNED NOT NULL,
        surl          VARCHAR(48) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
        identifier    VARCHAR(128) NOT NULL,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
          PRIMARY KEY (id),
          INDEX (surl),
          CONSTRAINT FOREIGN KEY (shortener_id) REFERENCES url_shorteners (id) ON DELETE RESTRICT,
          CONSTRAINT FOREIGN KEY (origin_id) REFERENCES url_origins (id) ON DELETE RESTRICT,
          CONSTRAINT FOREIGN KEY (url_id) REFERENCES url_destinations (id) ON DELETE CASCADE
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE trim_urls_sequence
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        shortened_id  INTEGER UNSIGNED NOT NULL,
          PRIMARY KEY (id),
          CONSTRAINT FOREIGN KEY (shortened_id) REFERENCES url_shortenings (id) ON DELETE CASCADE
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE trim_urls
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        shortened_id  INTEGER UNSIGNED NOT NULL,
        return_id     TINYINT UNSIGNED NOT NULL,
        reference     VARCHAR(30) NOT NULL,
        title         VARCHAR(48),
        custom        VARCHAR(48),
        privacy       VARCHAR(48),
        searchtags    VARCHAR(255),
        description   VARCHAR(512),
        deletion      ENUM('YES','NO') NOT NULL DEFAULT 'NO',
        clicks        INTEGER UNSIGNED NOT NULL DEFAULT 0,
        version       INTEGER UNSIGNED NOT NULL DEFAULT 0,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          INDEX (custom),
          INDEX (privacy),
          INDEX (deletion),
          INDEX (created_at),
          CONSTRAINT UNIQUE (reference),
          CONSTRAINT FOREIGN KEY (shortened_id) REFERENCES url_shortenings (id) ON DELETE CASCADE,
          CONSTRAINT FOREIGN KEY (return_id) REFERENCES url_returns (id) ON DELETE RESTRICT
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE trim_namespace
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        surl          VARCHAR(12) NOT NULL,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (surl)
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE trim_claimants
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        user_id       INTEGER UNSIGNED NOT NULL,
        oauth_id      INTEGER UNSIGNED NOT NULL,
        status_id     INTEGER UNSIGNED NOT NULL DEFAULT 0,
        checked_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          INDEX (checked_at),
          CONSTRAINT UNIQUE (user_id, oauth_id),
          CONSTRAINT FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
          CONSTRAINT FOREIGN KEY (oauth_id) REFERENCES network_o_auths (id) ON DELETE CASCADE
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
    
    execute <<-SQL
      CREATE TABLE trim_clicks
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        trim_url_id   INTEGER UNSIGNED NOT NULL,
        country_id    TINYINT UNSIGNED NOT NULL DEFAULT 255,
        region_id     INTEGER UNSIGNED NOT NULL DEFAULT 1,
        city_id       INTEGER UNSIGNED NOT NULL DEFAULT 1,
        agent_id      INTEGER UNSIGNED NOT NULL DEFAULT 1,
        ip_address    VARCHAR(15) NOT NULL,
        referer       VARCHAR(128),
        version       INTEGER UNSIGNED NOT NULL DEFAULT 0,
        summarized    INTEGER UNSIGNED NOT NULL DEFAULT 0,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          INDEX (summarized),
          CONSTRAINT FOREIGN KEY (trim_url_id) REFERENCES trim_urls (id) ON DELETE CASCADE,
          CONSTRAINT FOREIGN KEY (country_id) REFERENCES countries (id) ON DELETE RESTRICT,
          CONSTRAINT FOREIGN KEY (region_id) REFERENCES regions (id) ON DELETE RESTRICT
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE trim_user_urls
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        user_id       INTEGER UNSIGNED NOT NULL,
        trim_url_id   INTEGER UNSIGNED NOT NULL,
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (trim_url_id),
          CONSTRAINT FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
          CONSTRAINT FOREIGN KEY (trim_url_id) REFERENCES trim_urls (id) ON DELETE CASCADE
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE trim_session_urls
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        session_id    VARCHAR(128) NOT NULL,
        trim_url_id   INTEGER UNSIGNED NOT NULL,
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (trim_url_id),
          CONSTRAINT FOREIGN KEY (trim_url_id) REFERENCES trim_urls (id) ON DELETE CASCADE
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
      
    execute <<-SQL      
      CREATE TABLE trim_groups
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        user_id       INTEGER UNSIGNED NOT NULL,
        name          VARCHAR(32) NOT NULL,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          CONSTRAINT FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE trim_group_urls
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        group_id      INTEGER UNSIGNED NOT NULL,
        trim_url_id   INTEGER UNSIGNED NOT NULL,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          CONSTRAINT FOREIGN KEY (group_id) REFERENCES trim_groups (id) ON DELETE CASCADE,
          CONSTRAINT FOREIGN KEY (trim_url_id) REFERENCES trim_urls (id) ON DELETE CASCADE
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
    
    execute <<-SQL
      CREATE TABLE trim_tweets
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        oauth_id      INTEGER UNSIGNED NOT NULL,
        user_id       INTEGER UNSIGNED NOT NULL,
        trim_url_id   INTEGER UNSIGNED NOT NULL,
        tweet         VARCHAR(180) NOT NULL,
        tweet_id      INTEGER UNSIGNED NOT NULL,
        remote_id     INTEGER UNSIGNED NOT NULL,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
          PRIMARY KEY (id),
          INDEX (created_at),
          CONSTRAINT FOREIGN KEY (oauth_id) REFERENCES network_o_auths (id) ON DELETE RESTRICT,
          CONSTRAINT FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
          CONSTRAINT FOREIGN KEY (trim_url_id) REFERENCES trim_urls (id) ON DELETE CASCADE
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
    
    execute <<-SQL
      CREATE TABLE trim_actions
      (
        id            TINYINT UNSIGNED NOT NULL,
        action        VARCHAR(18) NOT NULL,
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (action)
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE trim_activity
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        action_id     TINYINT UNSIGNED NOT NULL,
        country_id    TINYINT UNSIGNED NOT NULL DEFAULT 255,
        session_id    VARCHAR(128) NOT NULL,
        ip_address    VARCHAR(15) NOT NULL,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
          PRIMARY KEY (id),
          INDEX (session_id),
          INDEX (ip_address),
          INDEX (action_id, created_at),
          CONSTRAINT FOREIGN KEY (action_id) REFERENCES trim_actions (id) ON DELETE RESTRICT,
          CONSTRAINT FOREIGN KEY (country_id) REFERENCES countries (id) ON DELETE RESTRICT
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE trim_preferences
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        trimtweet     ENUM('YES','NO') NOT NULL DEFAULT 'YES',
        savepwds      ENUM('YES','NO') NOT NULL DEFAULT 'YES',
        autosubmit    ENUM('YES','NO') NOT NULL DEFAULT 'YES',
        newforstats   ENUM('YES','NO') NOT NULL DEFAULT 'YES',
        comments      ENUM('YES','NO') NOT NULL DEFAULT 'YES',
        copypaste     ENUM('YES','NO') NOT NULL DEFAULT 'YES',
        return_id     TINYINT UNSIGNED NOT NULL DEFAULT 1,
        urlsort       TINYINT UNSIGNED NOT NULL DEFAULT 2,
        urlsppage     TINYINT UNSIGNED NOT NULL DEFAULT 5,
        picsort       TINYINT UNSIGNED NOT NULL DEFAULT 0,
        picsppage     TINYINT UNSIGNED NOT NULL DEFAULT 8,
        charts        ENUM('FLASH','PCHART') NOT NULL DEFAULT 'FLASH',
        statspublic   ENUM('YES','NO') NOT NULL DEFAULT 'NO',
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          CONSTRAINT FOREIGN KEY (return_id) REFERENCES url_returns (id) ON DELETE RESTRICT
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
      
    execute <<-SQL
      CREATE TABLE trim_preferences_users
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        user_id       INTEGER UNSIGNED NOT NULL,
        prefs_id      INTEGER UNSIGNED NOT NULL,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (user_id, prefs_id),
          INDEX (user_id),
          CONSTRAINT FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
          CONSTRAINT FOREIGN KEY (prefs_id) REFERENCES trim_preferences (id) ON DELETE CASCADE
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE trim_preferences_anonymous
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        session_id    VARCHAR(128) NOT NULL,
        prefs_id      INTEGER UNSIGNED NOT NULL,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (session_id, prefs_id),
          INDEX (session_id),
          CONSTRAINT FOREIGN KEY (prefs_id) REFERENCES trim_preferences (id) ON DELETE CASCADE
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
    

    ## Private Domain Names and URLs
    execute <<-SQL
      CREATE TABLE private_domains
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        user_id       INTEGER UNSIGNED NOT NULL,
        domain        VARCHAR(48) NOT NULL,
        sequence      INTEGER UNSIGNED NOT NULL DEFAULT 25000,
        version       INTEGER UNSIGNED NOT NULL DEFAULT 1,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          CONSTRAINT UNIQUE (domain),
          CONSTRAINT FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE RESTRICT
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE private_urls
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        url_id        INTEGER UNSIGNED NOT NULL,
        domain_id     INTEGER UNSIGNED NOT NULL,
        surl          VARCHAR(48) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
        title         VARCHAR(48),
        custom        VARCHAR(48),
        privacy       VARCHAR(48),
        searchtags    VARCHAR(255),
        description   VARCHAR(512),
        reference     VARCHAR(30) NOT NULL,
        clicks        INTEGER UNSIGNED NOT NULL DEFAULT 0,
        version       INTEGER UNSIGNED NOT NULL DEFAULT 1,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          INDEX (surl),
          INDEX (custom),
          INDEX (privacy),
          INDEX (created_at),
          CONSTRAINT UNIQUE (reference),
          CONSTRAINT FOREIGN KEY (url_id) REFERENCES url_destinations (id) ON DELETE CASCADE,
          CONSTRAINT FOREIGN KEY (domain_id) REFERENCES private_domains (id) ON DELETE CASCADE
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE private_clicks
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        purl_id       INTEGER UNSIGNED NOT NULL,
        country_id    TINYINT UNSIGNED NOT NULL DEFAULT 255,
        agent_id      INTEGER UNSIGNED NOT NULL DEFAULT 1,
        ip_address    VARCHAR(15) NOT NULL,
        referer       VARCHAR(128),
        summarized    TINYINT UNSIGNED NOT NULL DEFAULT 0,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          CONSTRAINT FOREIGN KEY (purl_id) REFERENCES private_urls (id) ON DELETE CASCADE,
          CONSTRAINT FOREIGN KEY (country_id) REFERENCES countries (id) ON DELETE RESTRICT,
          CONSTRAINT FOREIGN KEY (agent_id) REFERENCES user_agents (id) ON DELETE RESTRICT
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
    

    ## Clicks Summaries Tables -- NOT YET IN USE
    execute <<-SQL
      CREATE TABLE trim_summaries_countries
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        trim_url_id   INTEGER UNSIGNED NOT NULL,
        country_id    TINYINT UNSIGNED NOT NULL,
        total         INTEGER UNSIGNED NOT NULL DEFAULT 0,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          CONSTRAINT FOREIGN KEY (trim_url_id) REFERENCES trim_urls (id) ON DELETE CASCADE,
          CONSTRAINT FOREIGN KEY (country_id) REFERENCES countries (id) ON DELETE RESTRICT
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE trim_summaries_regions
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        trim_url_id   INTEGER UNSIGNED NOT NULL,
        country_id    TINYINT UNSIGNED NOT NULL,
        region_id     INTEGER UNSIGNED NOT NULL,
        total         INTEGER UNSIGNED NOT NULL DEFAULT 0,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          CONSTRAINT FOREIGN KEY (trim_url_id) REFERENCES trim_urls (id) ON DELETE CASCADE,
          CONSTRAINT FOREIGN KEY (country_id) REFERENCES countries (id) ON DELETE RESTRICT,
          CONSTRAINT FOREIGN KEY (region_id) REFERENCES regions (id) ON DELETE RESTRICT
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE trim_summaries_cities
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        trim_url_id   INTEGER UNSIGNED NOT NULL,
        country_id    TINYINT UNSIGNED NOT NULL,
        city_id       INTEGER UNSIGNED NOT NULL,
        total         INTEGER UNSIGNED NOT NULL DEFAULT 0,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          CONSTRAINT FOREIGN KEY (trim_url_id) REFERENCES trim_urls (id) ON DELETE CASCADE,
          CONSTRAINT FOREIGN KEY (country_id) REFERENCES countries (id) ON DELETE RESTRICT,
          CONSTRAINT FOREIGN KEY (city_id) REFERENCES cities (id) ON DELETE RESTRICT
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE trim_summaries_referers
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        trim_url_id   INTEGER UNSIGNED NOT NULL,
        referer_id    INTEGER UNSIGNED NOT NULL,
        total         INTEGER UNSIGNED NOT NULL DEFAULT 0,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          CONSTRAINT FOREIGN KEY (trim_url_id) REFERENCES trim_urls (id) ON DELETE CASCADE,
          CONSTRAINT FOREIGN KEY (referer_id) REFERENCES referers (id) ON DELETE RESTRICT
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE trim_summaries_agents
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        trim_url_id   INTEGER UNSIGNED NOT NULL,
        agent_id      INTEGER UNSIGNED NOT NULL,
        total         INTEGER UNSIGNED NOT NULL DEFAULT 0,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          CONSTRAINT FOREIGN KEY (trim_url_id) REFERENCES trim_urls (id) ON DELETE CASCADE,
          CONSTRAINT FOREIGN KEY (agent_id) REFERENCES user_agents (id) ON DELETE RESTRICT
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL


    ## Statistics Tables
    execute <<-SQL
      CREATE TABLE statistics_urls
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        website_id    TINYINT UNSIGNED NOT NULL,
        tdate         DATE NOT NULL,
        total         INTEGER NOT NULL DEFAULT 0,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          CONSTRAINT FOREIGN KEY (website_id) REFERENCES websites (id) ON DELETE CASCADE
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
    
    execute <<-SQL
      CREATE TABLE statistics_tweets
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        website_id    TINYINT UNSIGNED NOT NULL,
        tdate         DATE NOT NULL,
        total         INTEGER NOT NULL DEFAULT 0,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          CONSTRAINT FOREIGN KEY (website_id) REFERENCES websites (id) ON DELETE CASCADE
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL

    execute <<-SQL
      CREATE TABLE statistics_signups
      (
        id            INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        website_id    TINYINT UNSIGNED NOT NULL,
        tdate         DATE NOT NULL,
        total         INTEGER NOT NULL DEFAULT 0,
        created_at    TIMESTAMP(14) NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at    TIMESTAMP(14) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          CONSTRAINT FOREIGN KEY (website_id) REFERENCES websites (id) ON DELETE CASCADE
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
    

    ## Sessions Table
    execute <<-SQL
      CREATE TABLE sessions (
        id           INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        session_id   VARCHAR(255) DEFAULT NULL,
        data         TEXT,
        updated_at   DATETIME DEFAULT NULL,
          PRIMARY KEY (id),
          KEY index_sessions_on_session_id (session_id),
          KEY index_sessions_on_updated_at (updated_at)
      ) ENGINE=InnoDB CHARACTER SET utf8 ROW_FORMAT=DYNAMIC;
    SQL
  end
  
  def self.down
    ## N/A
  end
end
