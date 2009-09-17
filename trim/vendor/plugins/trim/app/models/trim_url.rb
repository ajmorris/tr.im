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

class TrimUrl < ActiveRecord::Base
  before_destroy :set_namespace
  
  DELETION_Q = "DELETION_TRIM"
  CLICKS_Q = "CLICKS_TRIM"
  RESET_Q = "RESET_TRIM"
  SUMMARIES_Q = "SUMMARIES_TRIM"
  
  DELETION_NO = "NO"
  DELETION_YES = "YES"
  RESET_NO = "NO"
  RESET_YES = "YES"
  DELETION_NEEDED = 500                             ## If more clicks than this hand over to Starling to DELETE.
  
  URLSORT_DESTINATION = 0
  URLSORT_VISITS = 1
  URLSORT_TRIMMED = 2
  TRIMURL_REFERENCE_LENGTH = 30

  belongs_to :shortening, :class_name => "UrlShortening", :foreign_key => "shortened_id", :dependent => :destroy
  has_one  :trim_user_url
  has_many :trim_tweets, :dependent => :destroy
  has_many :trim_clicks, :order => "id DESC"

  validates_format_of :custom, :with => /^\w+$/i, :allow_nil => true, :allow_blank => true
  validates_format_of :privacy, :with => /^\w+$/i, :allow_nil => true, :allow_blank => true

  def has_title?
    return true if not self.title.blank?
    return false
  end

  def has_clicks?
    return true if self.clicks_count >= 1
    return false
  end
  def clicks_count
    ## self.trim_clicks.size
    self.clicks
  end
  def clicks_since(seconds_ago)
    count = 0
    self.trim_clicks.each do |click| count += 1 if click.created_at > seconds_ago.seconds.ago end
    return count
  end

  def age_in_days
    (DateTime.now).to_date - self.created_at.to_date
  end
  
  def has_tweet?
    return true if not self.trim_tweets.empty?
    return false
  end
  def url_tweet
    self.trim_tweets[0]
  end
  
  def return_status
    return "REDIRECTION" if self.return_id == UrlReturn::REDIRECT
    return "SPAM" if self.return_id == UrlReturn::SPAM
    return "UNKNOWN"
  end
  
  def has_privacy?
    return true if self.privacy && self.privacy.length >= 2
    return false
  end
  def custom?
    return true unless self.custom.blank?
    return false
  end
  def circular?
    return true if self.circular == CIRCULAR_YES
    return false
  end

  def belongs_to_user?(user_id)
    return true if self.trim_user_url && self.trim_user_url.user_id == user_id
    return false
  end
  def belongs_to_someone?
    return true if self.trim_user_url && self.trim_user_url.user_id > 0
    return false
  end
  def owning_user_id
    return self.trim_user_url.user_id if self.belongs_to_someone?
    return nil
  end

  def reset_stats!
    TrimClick.destroy_all(:trim_url_id => self.id)
    self.clicks = 0
    self.save!
  end

  protected
  def set_namespace
    surl = self.shortening.surl if self.shortening
    if not surl.blank? && (not self.custom?)
      if not UrlShortening.exists?({ :shortener_id => UrlShortener::ID_TRIM, :surl => surl })
        TrimNamespace.create!(:surl => surl) if not TrimNamespace.exists?({ :surl => surl })
      end
    end
  end
end
