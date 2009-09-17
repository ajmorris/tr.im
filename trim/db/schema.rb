# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 1) do

  create_table "api_hits", :force => true do |t|
    t.integer   "method_id",  :limit => 1,                 :null => false
    t.string    "ip_address", :limit => 15,                :null => false
    t.string    "day",        :limit => 10,                :null => false
    t.string    "hour",       :limit => 2,                 :null => false
    t.integer   "count",                    :default => 0, :null => false
    t.integer   "version",                  :default => 0, :null => false
    t.timestamp "created_at",                              :null => false
    t.timestamp "updated_at",                              :null => false
  end

  add_index "api_hits", ["method_id", "ip_address", "day", "hour"], :name => "method_id", :unique => true

  create_table "api_hits_keys", :force => true do |t|
    t.integer   "method_id",  :limit => 1,                 :null => false
    t.integer   "api_key_id",                              :null => false
    t.string    "day",        :limit => 10,                :null => false
    t.string    "hour",       :limit => 2,                 :null => false
    t.integer   "count",                    :default => 0, :null => false
    t.integer   "version",                  :default => 0, :null => false
    t.timestamp "created_at",                              :null => false
    t.timestamp "updated_at",                              :null => false
  end

  add_index "api_hits_keys", ["api_key_id"], :name => "api_key_id"
  add_index "api_hits_keys", ["method_id", "api_key_id", "day", "hour"], :name => "method_id", :unique => true

  create_table "api_keys", :force => true do |t|
    t.integer   "website_id", :limit => 1,                        :null => false
    t.string    "api_key",    :limit => 48,                       :null => false
    t.string    "name",       :limit => 32,                       :null => false
    t.string    "url",        :limit => 32,                       :null => false
    t.string    "email",      :limit => 32,                       :null => false
    t.string    "bypass",     :limit => 0,  :default => "NO",     :null => false
    t.string    "status",     :limit => 0,  :default => "ACTIVE", :null => false
    t.timestamp "created_at",                                     :null => false
    t.timestamp "updated_at",                                     :null => false
  end

  add_index "api_keys", ["website_id", "api_key"], :name => "website_id", :unique => true

  create_table "api_limits", :force => true do |t|
    t.integer "method_id", :limit => 1,                   :null => false
    t.integer "hour",                                     :null => false
    t.integer "day",                                      :null => false
    t.string  "reqkey",    :limit => 0, :default => "NO", :null => false
  end

  add_index "api_limits", ["method_id"], :name => "method_id", :unique => true

  create_table "api_methods", :force => true do |t|
    t.integer "website_id", :limit => 1,                    :null => false
    t.string  "code",       :limit => 32,                   :null => false
    t.string  "name",       :limit => 32,                   :null => false
    t.string  "restricted", :limit => 0,  :default => "NO", :null => false
    t.string  "nambuonly",  :limit => 0,  :default => "NO", :null => false
  end

  add_index "api_methods", ["website_id", "code"], :name => "website_id", :unique => true

  create_table "api_overrides", :force => true do |t|
    t.integer "api_key_id",              :null => false
    t.integer "method_id",  :limit => 1, :null => false
    t.integer "hour",                    :null => false
    t.integer "day",                     :null => false
  end

  add_index "api_overrides", ["api_key_id", "method_id"], :name => "api_key_id", :unique => true
  add_index "api_overrides", ["method_id"], :name => "method_id"

  create_table "cities", :force => true do |t|
    t.integer "country_id", :limit => 1,   :null => false
    t.integer "region_id"
    t.string  "name",       :limit => 128, :null => false
    t.string  "display",    :limit => 128, :null => false
  end

  add_index "cities", ["country_id"], :name => "country_id"
  add_index "cities", ["name"], :name => "name"
  add_index "cities", ["region_id"], :name => "region_id"

  create_table "countries", :force => true do |t|
    t.string "code", :limit => 2,   :null => false
    t.string "name", :limit => 128, :null => false
  end

  add_index "countries", ["code"], :name => "code", :unique => true

  create_table "emails", :force => true do |t|
    t.integer "website_id", :limit => 1,  :null => false
    t.string  "code",       :limit => 24, :null => false
  end

  add_index "emails", ["code"], :name => "code", :unique => true
  add_index "emails", ["website_id"], :name => "website_id"

  create_table "ip_cities", :id => false, :force => true do |t|
    t.integer "ip_from",                     :default => 0, :null => false
    t.integer "ip_to",                       :default => 0, :null => false
    t.string  "country_code", :limit => 2,                  :null => false
    t.string  "country_name", :limit => 64,                 :null => false
    t.string  "region",       :limit => 128,                :null => false
    t.string  "city",         :limit => 128,                :null => false
  end

  create_table "ip_countries", :id => false, :force => true do |t|
    t.integer "ip_from",                    :null => false
    t.integer "ip_to",                      :null => false
    t.string  "country_code", :limit => 2,  :null => false
    t.string  "country_name", :limit => 64, :null => false
  end

  add_index "ip_countries", ["ip_from", "ip_to"], :name => "ip_from"
  add_index "ip_countries", ["ip_from"], :name => "index_ipfrom"
  add_index "ip_countries", ["ip_to"], :name => "index_ipto"

  create_table "languages", :force => true do |t|
    t.string "code",    :limit => 2,  :null => false
    t.string "name_en", :limit => 24, :null => false
    t.string "name_nt", :limit => 24, :null => false
  end

  create_table "network_o_auths", :force => true do |t|
    t.integer   "website_id", :limit => 1,                         :null => false
    t.integer   "network_id", :limit => 1,                         :null => false
    t.string    "username",   :limit => 48, :default => "UNKNOWN", :null => false
    t.integer   "user_id",                  :default => 0,         :null => false
    t.string    "req_token",  :limit => 64,                        :null => false
    t.string    "acs_token",  :limit => 64, :default => "NONE",    :null => false
    t.string    "acs_secret", :limit => 64, :default => "NONE",    :null => false
    t.string    "status",     :limit => 0,  :default => "PENDING", :null => false
    t.timestamp "created_at",                                      :null => false
    t.timestamp "updated_at",                                      :null => false
  end

  add_index "network_o_auths", ["network_id"], :name => "network_id"
  add_index "network_o_auths", ["req_token"], :name => "req_token", :unique => true
  add_index "network_o_auths", ["website_id"], :name => "website_id"

  create_table "networks", :force => true do |t|
    t.string  "code",     :limit => 12, :null => false
    t.string  "name",     :limit => 32, :null => false
    t.string  "url",      :limit => 32, :null => false
    t.string  "domain",   :limit => 48, :null => false
    t.string  "api",      :limit => 32, :null => false
    t.integer "ordernum", :limit => 1,  :null => false
  end

  add_index "networks", ["name"], :name => "name", :unique => true
  add_index "networks", ["url"], :name => "url", :unique => true

  create_table "private_clicks", :force => true do |t|
    t.integer   "purl_id",                                    :null => false
    t.integer   "country_id", :limit => 1,   :default => 255, :null => false
    t.integer   "agent_id",                  :default => 1,   :null => false
    t.string    "ip_address", :limit => 15,                   :null => false
    t.string    "referer",    :limit => 128
    t.integer   "summarized", :limit => 1,   :default => 0,   :null => false
    t.timestamp "created_at",                                 :null => false
    t.timestamp "updated_at",                                 :null => false
  end

  add_index "private_clicks", ["agent_id"], :name => "agent_id"
  add_index "private_clicks", ["country_id"], :name => "country_id"
  add_index "private_clicks", ["purl_id"], :name => "purl_id"

  create_table "private_domains", :force => true do |t|
    t.integer   "user_id",                                     :null => false
    t.string    "domain",     :limit => 48,                    :null => false
    t.integer   "sequence",                 :default => 25000, :null => false
    t.integer   "version",                  :default => 1,     :null => false
    t.timestamp "created_at",                                  :null => false
    t.timestamp "updated_at",                                  :null => false
  end

  add_index "private_domains", ["domain"], :name => "domain", :unique => true
  add_index "private_domains", ["user_id"], :name => "user_id"

  create_table "private_urls", :force => true do |t|
    t.integer   "url_id",                                    :null => false
    t.integer   "domain_id",                                 :null => false
    t.string    "surl",        :limit => 48,                 :null => false
    t.string    "title",       :limit => 48
    t.string    "custom",      :limit => 48
    t.string    "privacy",     :limit => 48
    t.string    "searchtags"
    t.string    "description", :limit => 512
    t.string    "reference",   :limit => 30,                 :null => false
    t.integer   "clicks",                     :default => 0, :null => false
    t.integer   "version",                    :default => 1, :null => false
    t.timestamp "created_at",                                :null => false
    t.timestamp "updated_at",                                :null => false
  end

  add_index "private_urls", ["created_at"], :name => "created_at"
  add_index "private_urls", ["custom"], :name => "custom"
  add_index "private_urls", ["domain_id"], :name => "domain_id"
  add_index "private_urls", ["privacy"], :name => "privacy"
  add_index "private_urls", ["reference"], :name => "reference", :unique => true
  add_index "private_urls", ["surl"], :name => "surl"
  add_index "private_urls", ["url_id"], :name => "url_id"

  create_table "referers", :force => true do |t|
    t.string    "url",        :null => false
    t.timestamp "created_at", :null => false
  end

  add_index "referers", ["url"], :name => "url", :unique => true

  create_table "regions", :force => true do |t|
    t.integer "country_id", :limit => 1,   :null => false
    t.string  "name",       :limit => 128, :null => false
    t.string  "display",    :limit => 128, :null => false
  end

  add_index "regions", ["country_id"], :name => "country_id"
  add_index "regions", ["name"], :name => "name"

  create_table "session_o_auths", :force => true do |t|
    t.integer "oauth_id",                  :null => false
    t.string  "session_id", :limit => 128, :null => false
  end

  add_index "session_o_auths", ["oauth_id", "session_id"], :name => "oauth_id", :unique => true
  add_index "session_o_auths", ["session_id"], :name => "session_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "statistics_signups", :force => true do |t|
    t.integer   "website_id", :limit => 1,                :null => false
    t.date      "tdate",                                  :null => false
    t.integer   "total",                   :default => 0, :null => false
    t.timestamp "created_at",                             :null => false
    t.timestamp "updated_at",                             :null => false
  end

  add_index "statistics_signups", ["website_id"], :name => "website_id"

  create_table "statistics_tweets", :force => true do |t|
    t.integer   "website_id", :limit => 1,                :null => false
    t.date      "tdate",                                  :null => false
    t.integer   "total",                   :default => 0, :null => false
    t.timestamp "created_at",                             :null => false
    t.timestamp "updated_at",                             :null => false
  end

  add_index "statistics_tweets", ["website_id"], :name => "website_id"

  create_table "statistics_urls", :force => true do |t|
    t.integer   "website_id", :limit => 1,                :null => false
    t.date      "tdate",                                  :null => false
    t.integer   "total",                   :default => 0, :null => false
    t.timestamp "created_at",                             :null => false
    t.timestamp "updated_at",                             :null => false
  end

  add_index "statistics_urls", ["website_id"], :name => "website_id"

  create_table "tlds", :force => true do |t|
    t.string "tld", :limit => 32, :null => false
  end

  add_index "tlds", ["tld"], :name => "tld", :unique => true

  create_table "trim_actions", :force => true do |t|
    t.string "action", :limit => 18, :null => false
  end

  add_index "trim_actions", ["action"], :name => "action", :unique => true

  create_table "trim_activity", :force => true do |t|
    t.integer   "action_id",  :limit => 1,                    :null => false
    t.integer   "country_id", :limit => 1,   :default => 255, :null => false
    t.string    "session_id", :limit => 128,                  :null => false
    t.string    "ip_address", :limit => 15,                   :null => false
    t.timestamp "created_at",                                 :null => false
  end

  add_index "trim_activity", ["action_id", "created_at"], :name => "action_id"
  add_index "trim_activity", ["country_id"], :name => "country_id"
  add_index "trim_activity", ["ip_address"], :name => "ip_address"
  add_index "trim_activity", ["session_id"], :name => "session_id"

  create_table "trim_claimants", :force => true do |t|
    t.integer   "user_id",                   :null => false
    t.integer   "oauth_id",                  :null => false
    t.integer   "status_id",  :default => 0, :null => false
    t.timestamp "checked_at",                :null => false
    t.timestamp "created_at",                :null => false
    t.timestamp "updated_at",                :null => false
  end

  add_index "trim_claimants", ["checked_at"], :name => "checked_at"
  add_index "trim_claimants", ["oauth_id"], :name => "oauth_id"
  add_index "trim_claimants", ["user_id", "oauth_id"], :name => "user_id", :unique => true

  create_table "trim_clicks", :force => true do |t|
    t.integer   "trim_url_id",                                 :null => false
    t.integer   "country_id",  :limit => 1,   :default => 255, :null => false
    t.integer   "region_id",                  :default => 1,   :null => false
    t.integer   "city_id",                    :default => 1,   :null => false
    t.integer   "agent_id",                   :default => 1,   :null => false
    t.string    "ip_address",  :limit => 15,                   :null => false
    t.string    "referer",     :limit => 128
    t.integer   "version",                    :default => 0,   :null => false
    t.integer   "summarized",                 :default => 0,   :null => false
    t.timestamp "created_at",                                  :null => false
    t.timestamp "updated_at",                                  :null => false
  end

  add_index "trim_clicks", ["country_id"], :name => "country_id"
  add_index "trim_clicks", ["region_id"], :name => "region_id"
  add_index "trim_clicks", ["summarized"], :name => "summarized"
  add_index "trim_clicks", ["trim_url_id"], :name => "trim_url_id"

  create_table "trim_group_urls", :force => true do |t|
    t.integer   "group_id",    :null => false
    t.integer   "trim_url_id", :null => false
    t.timestamp "created_at",  :null => false
    t.timestamp "updated_at",  :null => false
  end

  add_index "trim_group_urls", ["group_id"], :name => "group_id"
  add_index "trim_group_urls", ["trim_url_id"], :name => "trim_url_id"

  create_table "trim_groups", :force => true do |t|
    t.integer   "user_id",                  :null => false
    t.string    "name",       :limit => 32, :null => false
    t.timestamp "created_at",               :null => false
    t.timestamp "updated_at",               :null => false
  end

  add_index "trim_groups", ["user_id"], :name => "user_id"

  create_table "trim_namespace", :force => true do |t|
    t.string    "surl",       :limit => 12, :null => false
    t.timestamp "created_at",               :null => false
  end

  add_index "trim_namespace", ["surl"], :name => "surl", :unique => true

  create_table "trim_preferences", :force => true do |t|
    t.string    "trimtweet",   :limit => 0, :default => "YES",   :null => false
    t.string    "savepwds",    :limit => 0, :default => "YES",   :null => false
    t.string    "autosubmit",  :limit => 0, :default => "YES",   :null => false
    t.string    "newforstats", :limit => 0, :default => "YES",   :null => false
    t.string    "comments",    :limit => 0, :default => "YES",   :null => false
    t.string    "copypaste",   :limit => 0, :default => "YES",   :null => false
    t.integer   "return_id",   :limit => 1, :default => 1,       :null => false
    t.integer   "urlsort",     :limit => 1, :default => 2,       :null => false
    t.integer   "urlsppage",   :limit => 1, :default => 5,       :null => false
    t.integer   "picsort",     :limit => 1, :default => 0,       :null => false
    t.integer   "picsppage",   :limit => 1, :default => 8,       :null => false
    t.string    "charts",      :limit => 0, :default => "FLASH", :null => false
    t.string    "statspublic", :limit => 0, :default => "NO",    :null => false
    t.timestamp "created_at",                                    :null => false
    t.timestamp "updated_at",                                    :null => false
  end

  add_index "trim_preferences", ["return_id"], :name => "return_id"

  create_table "trim_preferences_anonymous", :force => true do |t|
    t.string    "session_id", :limit => 128, :null => false
    t.integer   "prefs_id",                  :null => false
    t.timestamp "created_at",                :null => false
    t.timestamp "updated_at",                :null => false
  end

  add_index "trim_preferences_anonymous", ["prefs_id"], :name => "prefs_id"
  add_index "trim_preferences_anonymous", ["session_id", "prefs_id"], :name => "session_id", :unique => true
  add_index "trim_preferences_anonymous", ["session_id"], :name => "session_id_2"

  create_table "trim_preferences_users", :force => true do |t|
    t.integer   "user_id",    :null => false
    t.integer   "prefs_id",   :null => false
    t.timestamp "created_at", :null => false
    t.timestamp "updated_at", :null => false
  end

  add_index "trim_preferences_users", ["prefs_id"], :name => "prefs_id"
  add_index "trim_preferences_users", ["user_id", "prefs_id"], :name => "user_id", :unique => true
  add_index "trim_preferences_users", ["user_id"], :name => "user_id_2"

  create_table "trim_session_urls", :force => true do |t|
    t.string  "session_id",  :limit => 128, :null => false
    t.integer "trim_url_id",                :null => false
  end

  add_index "trim_session_urls", ["trim_url_id"], :name => "trim_url_id", :unique => true

  create_table "trim_summaries_agents", :force => true do |t|
    t.integer   "trim_url_id",                :null => false
    t.integer   "agent_id",                   :null => false
    t.integer   "total",       :default => 0, :null => false
    t.timestamp "created_at",                 :null => false
    t.timestamp "updated_at",                 :null => false
  end

  add_index "trim_summaries_agents", ["agent_id"], :name => "agent_id"
  add_index "trim_summaries_agents", ["trim_url_id"], :name => "trim_url_id"

  create_table "trim_summaries_cities", :force => true do |t|
    t.integer   "trim_url_id",                             :null => false
    t.integer   "country_id",  :limit => 1,                :null => false
    t.integer   "city_id",                                 :null => false
    t.integer   "total",                    :default => 0, :null => false
    t.timestamp "created_at",                              :null => false
    t.timestamp "updated_at",                              :null => false
  end

  add_index "trim_summaries_cities", ["city_id"], :name => "city_id"
  add_index "trim_summaries_cities", ["country_id"], :name => "country_id"
  add_index "trim_summaries_cities", ["trim_url_id"], :name => "trim_url_id"

  create_table "trim_summaries_countries", :force => true do |t|
    t.integer   "trim_url_id",                             :null => false
    t.integer   "country_id",  :limit => 1,                :null => false
    t.integer   "total",                    :default => 0, :null => false
    t.timestamp "created_at",                              :null => false
    t.timestamp "updated_at",                              :null => false
  end

  add_index "trim_summaries_countries", ["country_id"], :name => "country_id"
  add_index "trim_summaries_countries", ["trim_url_id"], :name => "trim_url_id"

  create_table "trim_summaries_referers", :force => true do |t|
    t.integer   "trim_url_id",                :null => false
    t.integer   "referer_id",                 :null => false
    t.integer   "total",       :default => 0, :null => false
    t.timestamp "created_at",                 :null => false
    t.timestamp "updated_at",                 :null => false
  end

  add_index "trim_summaries_referers", ["referer_id"], :name => "referer_id"
  add_index "trim_summaries_referers", ["trim_url_id"], :name => "trim_url_id"

  create_table "trim_summaries_regions", :force => true do |t|
    t.integer   "trim_url_id",                             :null => false
    t.integer   "country_id",  :limit => 1,                :null => false
    t.integer   "region_id",                               :null => false
    t.integer   "total",                    :default => 0, :null => false
    t.timestamp "created_at",                              :null => false
    t.timestamp "updated_at",                              :null => false
  end

  add_index "trim_summaries_regions", ["country_id"], :name => "country_id"
  add_index "trim_summaries_regions", ["region_id"], :name => "region_id"
  add_index "trim_summaries_regions", ["trim_url_id"], :name => "trim_url_id"

  create_table "trim_tweets", :force => true do |t|
    t.integer   "oauth_id",                   :null => false
    t.integer   "user_id",                    :null => false
    t.integer   "trim_url_id",                :null => false
    t.string    "tweet",       :limit => 180, :null => false
    t.integer   "tweet_id",                   :null => false
    t.integer   "remote_id",                  :null => false
    t.timestamp "created_at",                 :null => false
  end

  add_index "trim_tweets", ["created_at"], :name => "created_at"
  add_index "trim_tweets", ["oauth_id"], :name => "oauth_id"
  add_index "trim_tweets", ["trim_url_id"], :name => "trim_url_id"
  add_index "trim_tweets", ["user_id"], :name => "user_id"

  create_table "trim_urls", :force => true do |t|
    t.integer   "shortened_id",                                  :null => false
    t.integer   "return_id",    :limit => 1,                     :null => false
    t.string    "reference",    :limit => 30,                    :null => false
    t.string    "title",        :limit => 48
    t.string    "custom",       :limit => 48
    t.string    "privacy",      :limit => 48
    t.string    "searchtags"
    t.string    "description",  :limit => 512
    t.string    "deletion",     :limit => 0,   :default => "NO", :null => false
    t.integer   "clicks",                      :default => 0,    :null => false
    t.integer   "version",                     :default => 0,    :null => false
    t.timestamp "created_at",                                    :null => false
    t.timestamp "updated_at",                                    :null => false
  end

  add_index "trim_urls", ["created_at"], :name => "created_at"
  add_index "trim_urls", ["custom"], :name => "custom"
  add_index "trim_urls", ["deletion"], :name => "deletion"
  add_index "trim_urls", ["privacy"], :name => "privacy"
  add_index "trim_urls", ["reference"], :name => "reference", :unique => true
  add_index "trim_urls", ["return_id"], :name => "return_id"
  add_index "trim_urls", ["shortened_id"], :name => "shortened_id"

  create_table "trim_urls_sequence", :force => true do |t|
    t.integer "shortened_id", :null => false
  end

  add_index "trim_urls_sequence", ["shortened_id"], :name => "shortened_id"

  create_table "trim_user_urls", :force => true do |t|
    t.integer "user_id",     :null => false
    t.integer "trim_url_id", :null => false
  end

  add_index "trim_user_urls", ["trim_url_id"], :name => "trim_url_id", :unique => true
  add_index "trim_user_urls", ["user_id"], :name => "user_id"

  create_table "url_destinations", :force => true do |t|
    t.string    "url",        :limit => 2000, :null => false
    t.timestamp "created_at",                 :null => false
  end

  add_index "url_destinations", ["url"], :name => "url"

  create_table "url_origins", :force => true do |t|
    t.string "origin", :limit => 12, :null => false
  end

  add_index "url_origins", ["origin"], :name => "origin", :unique => true

  create_table "url_returns", :force => true do |t|
    t.string  "code",     :limit => 18,                   :null => false
    t.string  "name",     :limit => 48,                   :null => false
    t.string  "display",  :limit => 0,  :default => "NO", :null => false
    t.integer "ordernum", :limit => 1,                    :null => false
  end

  add_index "url_returns", ["code"], :name => "code", :unique => true
  add_index "url_returns", ["display"], :name => "display"
  add_index "url_returns", ["ordernum"], :name => "ordernum"

  create_table "url_shorteners", :force => true do |t|
    t.string "domain",    :limit => 32,                    :null => false
    t.string "nbprocess", :limit => 0,  :default => "YES", :null => false
    t.string "dmprocess", :limit => 0,  :default => "YES", :null => false
  end

  add_index "url_shorteners", ["domain"], :name => "domain", :unique => true

  create_table "url_shortenings", :force => true do |t|
    t.integer   "shortener_id", :limit => 1,   :null => false
    t.integer   "origin_id",    :limit => 1,   :null => false
    t.integer   "url_id",                      :null => false
    t.string    "surl",         :limit => 48,  :null => false
    t.string    "identifier",   :limit => 128, :null => false
    t.timestamp "created_at",                  :null => false
  end

  add_index "url_shortenings", ["origin_id"], :name => "origin_id"
  add_index "url_shortenings", ["shortener_id"], :name => "shortener_id"
  add_index "url_shortenings", ["surl"], :name => "surl"
  add_index "url_shortenings", ["url_id"], :name => "url_id"

  create_table "url_spam_domains", :force => true do |t|
    t.string    "domain",     :limit => 128, :null => false
    t.timestamp "created_at",                :null => false
    t.timestamp "updated_at",                :null => false
  end

  add_index "url_spam_domains", ["domain"], :name => "domain", :unique => true

  create_table "user_agent_filters", :force => true do |t|
    t.integer   "platform_id", :limit => 1, :null => false
    t.integer   "browser_id",  :limit => 1, :null => false
    t.timestamp "created_at",               :null => false
    t.timestamp "updated_at",               :null => false
  end

  add_index "user_agent_filters", ["browser_id"], :name => "browser_id"
  add_index "user_agent_filters", ["platform_id"], :name => "platform_id"

  create_table "user_agent_terms", :force => true do |t|
    t.integer   "filter_id",                :null => false
    t.string    "term",       :limit => 24, :null => false
    t.timestamp "created_at",               :null => false
    t.timestamp "updated_at",               :null => false
  end

  add_index "user_agent_terms", ["filter_id"], :name => "filter_id"

  create_table "user_agents", :force => true do |t|
    t.integer   "platform_id", :limit => 1, :default => 1, :null => false
    t.integer   "browser_id",  :limit => 1, :default => 1, :null => false
    t.string    "details",                                 :null => false
    t.timestamp "created_at",                              :null => false
    t.timestamp "updated_at",                              :null => false
  end

  add_index "user_agents", ["browser_id"], :name => "browser_id"
  add_index "user_agents", ["details"], :name => "details", :unique => true
  add_index "user_agents", ["platform_id"], :name => "platform_id"

  create_table "user_auto_logins", :force => true do |t|
    t.integer   "website_id", :limit => 1,  :null => false
    t.integer   "user_id",                  :null => false
    t.string    "reference",  :limit => 48, :null => false
    t.timestamp "created_at",               :null => false
  end

  add_index "user_auto_logins", ["user_id"], :name => "user_id"
  add_index "user_auto_logins", ["website_id", "reference"], :name => "website_id", :unique => true

  create_table "user_browsers", :force => true do |t|
    t.string "code", :limit => 18, :null => false
    t.string "name", :limit => 32, :null => false
  end

  add_index "user_browsers", ["name"], :name => "name", :unique => true

  create_table "user_disqus", :force => true do |t|
    t.integer   "website_id", :limit => 1,  :null => false
    t.integer   "user_id",                  :null => false
    t.string    "forum",      :limit => 48, :null => false
    t.timestamp "created_at",               :null => false
    t.timestamp "updated_at",               :null => false
  end

  add_index "user_disqus", ["user_id"], :name => "user_id"
  add_index "user_disqus", ["website_id", "forum"], :name => "website_id", :unique => true

  create_table "user_logins", :force => true do |t|
    t.integer   "user_id",                  :null => false
    t.string    "ip_address", :limit => 15, :null => false
    t.timestamp "created_at",               :null => false
    t.timestamp "updated_at",               :null => false
  end

  add_index "user_logins", ["user_id"], :name => "user_id"

  create_table "user_o_auths", :force => true do |t|
    t.integer "user_id",  :null => false
    t.integer "oauth_id", :null => false
  end

  add_index "user_o_auths", ["oauth_id"], :name => "oauth_id"
  add_index "user_o_auths", ["user_id", "oauth_id"], :name => "user_id", :unique => true

  create_table "user_platforms", :force => true do |t|
    t.string "code", :limit => 18, :null => false
    t.string "name", :limit => 32, :null => false
  end

  add_index "user_platforms", ["name"], :name => "name", :unique => true

  create_table "user_resets", :force => true do |t|
    t.integer   "user_id",                                         :null => false
    t.string    "code",       :limit => 32,                        :null => false
    t.string    "status",     :limit => 0,  :default => "PENDING", :null => false
    t.timestamp "created_at",                                      :null => false
    t.timestamp "updated_at",                                      :null => false
  end

  add_index "user_resets", ["code"], :name => "code", :unique => true
  add_index "user_resets", ["created_at"], :name => "created_at"
  add_index "user_resets", ["user_id"], :name => "user_id"

  create_table "users", :force => true do |t|
    t.integer   "website_id",  :limit => 1,                                             :null => false
    t.integer   "origin_id",   :limit => 1,                                             :null => false
    t.integer   "language_id", :limit => 1,                                             :null => false
    t.string    "name",        :limit => 48,                                            :null => false
    t.string    "email",       :limit => 96,                                            :null => false
    t.string    "login",       :limit => 48,                                            :null => false
    t.string    "salt",        :limit => 64,                                            :null => false
    t.string    "password",    :limit => 128,                                           :null => false
    t.string    "time_zone",   :limit => 48,  :default => "Eastern Time (US & Canada)", :null => false
    t.integer   "country_id",  :limit => 1,   :default => 255,                          :null => false
    t.string    "last_ip",     :limit => 15,                                            :null => false
    t.string    "source",      :limit => 0,   :default => "MANUAL",                     :null => false
    t.timestamp "last_seen",                                                            :null => false
    t.timestamp "created_at",                                                           :null => false
    t.timestamp "updated_at",                                                           :null => false
  end

  add_index "users", ["country_id"], :name => "country_id"
  add_index "users", ["language_id"], :name => "language_id"
  add_index "users", ["origin_id"], :name => "origin_id"
  add_index "users", ["website_id", "login"], :name => "website_id", :unique => true

  create_table "websites", :force => true do |t|
    t.string "name",        :limit => 32,                    :null => false
    t.string "domain",      :limit => 24,                    :null => false
    t.string "validations", :limit => 0,  :default => "YES", :null => false
  end

  add_index "websites", ["domain"], :name => "domain", :unique => true

end
