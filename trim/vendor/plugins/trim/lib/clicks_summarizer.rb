##
# Written by Eric Woodward, ejw@nambu.com.
# Copyright 2008-2009. The Nambu Network Inc. All Rights Reserved.
##

require 'ip_locator'
require 'trim_country'
require 'trim_url'
require 'trim_click'

class ClicksSummarizer
  attr_reader :countries

  def initialize
    @countries = TrimCountry.find(:all)
  end

  def do_trim_click(click_id)
    ## TBD
  end
end
