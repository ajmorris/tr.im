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

class NCTwitterTweet
  attr_accessor :status_id, :status, :source, :truncated, :favorited, :in_reply_status_id, :in_reply_user_id, :tweeted_at
  attr_accessor :user_id, :name, :screen_name, :url, :description, :location, :followers, :protected, :image_url, :language_code

  def retweet?
    self.status.split(/ /).each {|part| return true if part.downcase == "rt:" || part.downcase == "rt" }
    return false
  end

  def has_url?
    NCTweet.new(:text => self.status).has_url?
  end
  def get_urls
    NCTweet.new(:text => self.status).get_urls
  end
  
  def has_trim_url?
    return has_domain_in_url?("tr.im") if self.has_url?
    return false
  end
  def has_picim_url?
    return has_domain_in_url?("pic.im") if self.has_url?
    return false
  end

  def get_trim_url_paths
    self.get_paths("tr.im")
  end
  def get_picim_url_paths
    self.get_paths("pic.im")
  end
  
  protected
  def get_paths(domain)
    paths = []
    self.get_urls.each do |url|
      if url.include?(domain)
        i = url.index("/", 10)
        paths << url[i, url.length - 10]
      end
    end
    paths
  end
  def has_domain_in_url?(domain)
    self.get_urls.each {|url| return true if url.start_with?("http://#{domain}/") || url.start_with?("http://www.#{domain}/") }
    return false
  end
end
