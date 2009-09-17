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

##
# Trimmer() will tr.im the destination url you feed it, and do all the necessary database work as well. This function resides
# here to support the user website, marklet, and API creation options.
#
# This was the first class written for the tr.im project. It seems now, a year later (as I write this) this is a bit ugly,
# although I can't quite point to why. It works, anyway. The sequence: it seems there must be a more elegant way to track
# that peristent integer value.
#
# Trimmer() will raise the following exceptions, or return the trim_url object for you. It may be a new tr.im URK or a repeat
# for the same URL and same user account. You don't need to think about that here.
#   DomainErrorTooShort   
#   DomainErrorBadSyntax
#   DomainErrorShortener
#   DomainErrorSpam
#   DomainErrorCustomInuse
##

require 'uri'
require 'resolv'

require 'trim_object'
require 'top_level_domain'
require 'url_shortener'
 
class Trimmer
  attr_reader :dest_url, :surl, :trim_url, :trim_url_existed
  attr_accessor :urls, :token, :url_return_id, :url_origin_id, :custom, :privacy, :searchtags, :user_id, :force_new

  def initialize(hash = Hash.new)
    hash.each do |key, value|
      self.instance_variable_set("@#{key}", value)
      self.class.send(:define_method, key, proc{ self.instance_variable_get("@#{key}") })
      self.class.send(:define_method, "#{key}=", proc{|value| self.instance_variable_set("@#{key}", value) })
    end
    @urls ||= String.new
    @token ||= String.new
    @url_return_id ||= UrlReturn::REDIRECT
    @url_origin_id ||= UrlOrigin::TRIM
    @custom ||= String.new
    @privacy ||= String.new
    @searchtags ||= String.new 
    @user_id ||= nil
    @force_new ||= false
       
    @dest_url ||= nil              ## Ends up as UrlDestination()
    @surl ||= nil                  ## Ends up as UrlShortening()
    @trim_url ||= nil              ## Ends up as TrimUrl()
    @trim_url_existed ||= false
    
    self.prepare_url
  end
  
  def Trimmer.prepare_destination_url(urls)
    urls.strip!
    urls.sub!("ftp://ftp://", "ftp://")
    urls.sub!("http://http://", "http://")
    urls.sub!("https://https://", "https://")
    urls = "http://#{urls}" if (not urls.include?("://")) && (not urls.start_with?("mailto"))
    urls << "/" if (urls.index("/", 10) == nil) && (not urls.include?("?"))
    return urls
  end

  def valid_url?
    UrlDestination.new(:url => self.urls).valid_url?
  end
  def shortener_url?
    begin
      uri = URI.parse(self.get_url_qs_encoded(self.urls))
    rescue Exception => e then
      RAILS_DEFAULT_LOGGER.info e.inspect
      RAILS_DEFAULT_LOGGER.info "URL Validation Failed ON SHORTENERS: Bad URL [#{self.urls}]"
      return true
    end
    if uri
      for url_shortener in Rails.cache.fetch("url_shorteners", :expires_in => 7200) { UrlShortener.find(:all, :order => "domain") }
        if uri.host == url_shortener.domain || uri.host.include?(".#{url_shortener.domain}")
          RAILS_DEFAULT_LOGGER.info "SHORTENER MATCH on URI HOST: [#{uri.host} vs. #{url_shortener.domain}] ..."
          return true if (urls.count("/") < 4) && (urls.count("?") == 0) && (urls.count("=") == 0) && (urls.count("&") == 0)
        end
      end
    end
    return false
  end
  def spam_url?
    begin
      uri = URI.parse(self.get_url_qs_encoded(self.urls))
      domain = self.get_domainname(uri.host)
      RAILS_DEFAULT_LOGGER.info "SPAM Check DOMAIN [#{domain}]"
      if UrlSpamDomain.exists?({ :domain => domain })
        RAILS_DEFAULT_LOGGER.info "PRESENT in tr.im Spam Domains. SPAM!"
        return true
      end
    rescue Exception => e then
      RAILS_DEFAULT_LOGGER.info e.inspect
      RAILS_DEFAULT_LOGGER.info "URL Validation Failed: Bad URL ON SPAM [#{self.urls}]"
      return false
    end
    return false
  end
  def custom_url_claimed?
    reserved = ["account", "api", "application", "login", "redirect", "signup", "welcome", "photos", "browse", "events", "conversations",
      "comments", "review", "preview", "faqs", "reviews", "rss", "downloads", "logout", "nambu", "extras", "help", "picim" ]
    reserved.each {|res| return true if res == self.custom.downcase }
    if self.custom.length
      return true if TrimUrl.exists?(["custom = ?", self.custom.downcase])
      return true if UrlShortening.exists?({ :shortener_id => UrlShortener::ID_TRIM, :surl => self.custom.downcase })
    end
    return false
  end
  
  def force_new?
    self.force_new
  end
  def trim_url_was_new?
    (not self.trim_url_existed)
  end
 
  def create_trim_url
    raise DomainErrorTooShort if self.urls.length < UrlDestination::MINIMUM_URL_LENGTH
    raise DomainErrorBadSyntax if not valid_url?
    raise DomainErrorShortener if shortener_url?
    raise DomainErrorSpam if spam_url?
    raise DomainErrorCustomInuse if (not self.custom.blank?) && custom_url_claimed?
    
    RAILS_DEFAULT_LOGGER.info "Request to SHORTEN: [#{urls}]"
    UrlDestination.transaction do
      if UrlDestination.exists?({ :url => urls })
        RAILS_DEFAULT_LOGGER.info "Destination URL EXISTS [#{urls}]"
        @dest_url = UrlDestination.first(:conditions => { :url => self.urls })
      else
        RAILS_DEFAULT_LOGGER.info "Destination URL DOES NOT EXIST? [#{urls}]"
        @dest_url = UrlDestination.create!(:url => self.urls)
        if Rails.production?
          RAILS_DEFAULT_LOGGER.info "STARLING DESTINATION Q UPDATED [#{@dest_url.id}]"
        end
      end
    end

    if self.dest_url && self.dest_url.trim_shortened_count == 0
      self.insert_trimmed_url

    else
      if (not force_new?) && UrlShortening.exists?({ :shortener_id => UrlShortener::ID_TRIM,
                                                     :url_id => self.dest_url.id, :identifier => self.token })
        @surl = UrlShortening.first(:conditions => { :shortener_id => UrlShortener::ID_TRIM,
                                                     :url_id => self.dest_url.id, :identifier => self.token })
        @trim_url = TrimUrl.find_by_shortened_id(@surl.id)
        @trim_url_existed = true

      elsif (not force_new?) && self.user_id
        tu = TrimUrl.first(:select => "tu.*", :from => "trim_user_urls tuu, trim_urls tu, url_shortenings surls",
                           :conditions => ["tuu.user_id = ? AND tuu.trim_url_id = tu.id AND tu.shortened_id = surls.id AND surls.url_id = ?",
                                            user_id, @dest_url.id], :order => "tu.id DESC")
        if tu
          @trim_url = tu
          @surl = @trim_url.shortening
          @trim_url_existed = true
        else
          self.insert_trimmed_url end

      else
        self.insert_trimmed_url end
    end
    return @trim_url
  end
  def attach_trim_url(user_id)
    if not TrimUserUrl.exists?({ :trim_url_id => self.trim_url.id })
      TrimUserUrl.create!(:user_id => user_id, :trim_url_id => self.trim_url.id)
    else
      RAILS_DEFAULT_LOGGER.info "Attachment Attempted for Attached URL [User ID | #{user_id}]" end
  end
 
  protected
  def insert_trimmed_url
    ## If this a custom URL we do not need to grab a new one off the trim_url stack, we just go for it.
    ## Otherwise we grab one off the stack and try to use that. However, if it matches an already 
    ## existing custom URL we need to attach the sequence to that shortening and try again.
 
    UrlShortening.transaction do
      @surl = UrlShortening.new do |su|
        su[:shortener_id] = UrlShortener::ID_TRIM
        su[:origin_id] = self.url_origin_id
        su[:url_id] = self.dest_url.id
        su[:surl] = "REDONE_BELOW"
        su[:identifier] = self.token
      end
      @surl.save!
    end
    
    ## Because of prior issue with using base 16 and not base 64, and the need to switch to that and yet preserve
    ## prior made URLs we have to check if the short code has already been made with the prior scheme. Oh, legacy, 
    ## how we love thee.

    if self.custom.blank?
      available, basemade = false, String.new
      while not available
        sequence = TrimUrlSequence.create!(:shortened_id => @surl.id)
        basemade = TrimObject.get_basemade_value(sequence.id)
        if UrlShortening.exists?({ :shortener_id => UrlShortener::ID_TRIM, :surl => basemade })
          tmpshort = UrlShortening.first(:conditions => { :shortener_id => UrlShortener::ID_TRIM, :surl => basemade })
          sequence.shortened_id = tmpshort.id
        else
          if TrimUrl.exists?({ :custom => basemade })
            sequence.shortened_id = TrimUrl.first(:conditions => { :custom => basemade }).shortened_id
          else available = true end
        end
        sequence.save
      end
      @surl.surl = basemade
    else @surl.surl = custom.downcase.strip end
    @surl.save!

    tmprs = String.new
    begin
      tmprs = TrimObject.get_random_code(TrimUrl::TRIMURL_REFERENCE_LENGTH)
    end while TrimUrl.exists?({ :reference => tmprs })

    @trim_url = TrimUrl.new do |tu|
      tu[:shortened_id] = @surl.id
      tu[:return_id] = self.url_return_id
      tu[:reference] = tmprs
      tu[:custom] = self.custom.downcase if not self.custom.blank?
      tu[:privacy] = self.privacy.strip if not self.privacy.blank?
      tu[:searchtags] = self.searchtags.strip if not self.searchtags.blank?
    end
    @trim_url.save!
    attach_trim_url(self.user_id) if self.user_id
    RAILS_DEFAULT_LOGGER.info "Trimmer(): Created tr.im URL [#{@surl.surl}]"
    RAILS_DEFAULT_LOGGER.info "Trimmer(): Request to Attach to User ID [#{self.user_id}]" if self.user_id
  end
  
  def get_domainname(hostname)
    tlds = TopLevelDomain.find(:all)
    rval = String.new
    for tld in tlds
      if hostname.include?(".#{tld.tld}")
        rval = self.extract_domain(tld.tld.split(/\./).length, hostname)
        break
      end
    end
    rval = self.extract_domain(1, hostname) if rval.empty?
    return rval
  end
  def extract_domain(tldsize, hostname)
    rval = String.new
    nameparts = hostname.split(/\./)
    if (tldsize + 1) == nameparts.length
      rval = hostname
    else
      i = 0
      for part in nameparts
        if i >= (nameparts.length - tldsize - 1)
          rval.empty? ? rval = part : rval << ".#{part}"
        end
        i += 1
      end
    end
    return rval
  end
 
  def prepare_url
    @urls[0,4] = @urls[0,4].downcase                            ## Ensure scheme is lower case
  end
  def get_url_qs_encoded(urls)
    if i = urls.index("/", 10) : return "#{urls[0, i + 1]}#{CGI::escape(urls[i, urls.length - (i + 1)])}" end
    return urls
  end
end
