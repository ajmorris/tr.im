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
##Copyright 2008-2009. The Nambu Network Inc. All Rights Reserved.
##

require 'uri'
require 'cgi'

class UrlDestination < ActiveRecord::Base
  MINIMUM_URL_LENGTH = 10

  has_many :shortenings, :class_name => "UrlShortening", :foreign_key => "url_id", :order => "created_at DESC"
  has_many :shortenings_via_trim, :class_name => "UrlShortening", :foreign_key => "url_id",
                                  :conditions => { :shortener_id => UrlShortener::ID_TRIM }, :order => "created_at DESC"
  has_many :shortenings_via_others, :class_name => "UrlShortening", :foreign_key => "url_id",
                                     :conditions => ["shortener_id != ?", UrlShortener::ID_TRIM], :order => "created_at DESC"

  has_one :url_preview, :class_name => "UrlPreview", :foreign_key => "url_id"
  has_one :url_meta, :class_name => "UrlMeta", :foreign_key => "url_id"

  validates_length_of :url, :in => 8..2000
  validates_uniqueness_of :url

  def has_preview?
    return true if self.url_preview
    return false
  end
  def trimmed?
    return true if trim_shortened_count > 0
    return false
  end
  
  def shortened_count
    self.shortenings.size
  end
  def trim_shortened_count                     ## Method that returns how many times the URL has been
    self.shortenings.count {|i| i.origin_id == UrlShortener::ID_TRIM }          ## shortened by TR.IM
  end

  def valid_url?
    temp = self.get_url_qs_encoded(self.url)
    RAILS_DEFAULT_LOGGER.info "DOING: #{temp}"
    begin
      uri = URI.parse(self.get_url_qs_encoded(self.url))
    rescue Exception => e then
      RAILS_DEFAULT_LOGGER.info "URL Validation Failed: Bad URL [#{self.url}]"
      return false
    end
    schemet = self.url.downcase
    if (not schemet.starts_with?("https://")) && (not schemet.starts_with?("http://")) && (not schemet.starts_with?("ftp://")) && (not schemet.starts_with?("rtsp://"))
      RAILS_DEFAULT_LOGGER.info "URL Validation Failed: Bad Scheme [#{self.url}]"
      return false
    end
    if uri.host
      RAILS_DEFAULT_LOGGER.info "URL COUNT: #{uri.host}/#{uri.host.count(".")}"
      if uri.host.count(".") == 0
        RAILS_DEFAULT_LOGGER.info "URL Validation Failed: Bad '.' COUNT [#{uri.host.count(".")}]"
        return false end
    else
      RAILS_DEFAULT_LOGGER.info "URL Validation Failed: URI Nil?"
      return false
    end
    return true
  end
  def http?
    begin
      uri = URI.parse(self.url)
      return true if uri.scheme.downcase == "http"
    rescue Exception => e then
      RAILS_DEFAULT_LOGGER.info ".. http?(): URL Validation Failed: Bad URL [#{self.url}]"
    end
    return false
  end
  
  def binary?
    binaries = ["dmg", "bin", "exe", "zip", "gz", "tar", "mp3", "mp4", "mpeg", "nds", "wmv", "aa"]
    binaries.each {|fm| return true if self.endc(fm) }
    return false
  end
  def image?
    formats = ["jpg", "gif", "png"]
    formats.each {|fm| return true if self.endc(fm) }
    return false
  end

  def domain(tlds)                        ## TopLevelDomain.all
    begin
      uri = URI.parse(self.get_url_qs_encoded(self.url))
    rescue Exception => e then
      RAILS_DEFAULT_LOGGER.info "URL Validation FOR DOMAIN Failed: Bad URL [#{self.url}]"
      return nil
    end
    return self.get_domainname(uri.host, tlds)
  end
  def path
    path = nil
    begin
      uri = URI.parse(self.url)
      path = uri.path
      path = path[1, path.length - 2] if path.start_with?("/")
    rescue Exception => e then
      RAILS_DEFAULT_LOGGER.info ".. URL Validation Failed: Bad URL [#{self.url}]"
      return nil
    end
    return path
  end

  protected
  def get_url_qs_encoded(urls)
    if i = urls.index("/", 10)
      return "#{urls[0, i + 1]}#{CGI::escape(urls[i, urls.length - (i + 1)])}"
    else return urls end
  end
  def endc(fm)
    offset = fm.length + 4
    return true if self.url.length > (offset + 1) && self.url.index(".#{fm}", self.url.length - offset)
    return false
  end
  def get_domainname(hostname, tlds)
    rval = String.new
    for tld in tlds
      if hostname.include?(".#{tld.tld}")
        rval = extract_domain(tld.tld.split(/\./).length, hostname)
        break
      end
    end
    rval = extract_domain(1, hostname) if rval.empty?
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
          if rval.empty?
            rval = part
          else rval += ".#{part}" end
        end
        i += 1
      end
    end
    return rval
  end
end
