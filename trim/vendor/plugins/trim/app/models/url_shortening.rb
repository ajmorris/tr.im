##
# Written by Eric Woodward, ejw@nambu.com.
# Copyright 2008-2009. The Nambu Network Inc. All Rights Reserved.
##

class UrlShortening < ActiveRecord::Base
  belongs_to :shortener, :class_name => "UrlShortener", :foreign_key => "shortener_id"
  belongs_to :origin, :class_name => "UrlOrigin", :foreign_key => "origin_id"
  belongs_to :url_destination, :class_name => "UrlDestination", :foreign_key => "url_id"
  has_one :trim_url, :foreign_key => "shortened_id"
end
