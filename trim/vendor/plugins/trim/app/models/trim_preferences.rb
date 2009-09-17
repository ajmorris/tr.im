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

class TrimPreferences < ActiveRecord::Base
  has_one :user_preferences, :class_name => "TrimPreferencesUser", :foreign_key => "prefs_id"
  has_one :anonymous_preferences, :class_name => "TrimPreferencesAnonymous", :foreign_key => "prefs_id"
  
  CHARTS_FLASH = "FLASH"
  CHARTS_PCHART = "PCHART"
  
  def urls_per_page
    self.urlsppage
  end
  def pics_per_page
    self.picsppage
  end
  
  ## This preference determines whether or not the checkbox on the main trim form should default to checked, indicating
  ## if the users wants to go straight into the Tweet form with their new URL.

  def trim_tweet?
    self.trimtweet == 'YES'
  end

  ## Does the user want us storing their Twitter usernames and passwords? We can certainly speed things up for them -- 
  ## they will not have to repeatedly enter it, but then we are storing it. Not all that great.

  def save_passwords?
    self.savepwds == 'YES'
  end
  
  ## Does the user like the autosubmit of the tweet on the tweet form?
  
  def autosubmit_tweet?
    self.autosubmit == 'YES'
  end
  
  ## Does the user like a new window or tab for URL statistics?
  
  def new_statistics_page?
    self.newforstats == 'YES'
  end
  
  ## Which charting system are we using?

  def pcharts?
    self.charts == CHARTS_PCHART
  end
  def flash_charts?
    self.charts == CHARTS_FLASH
  end
end
