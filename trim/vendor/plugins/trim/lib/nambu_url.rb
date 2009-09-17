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

require 'uri'
require 'cgi'
require 'top_level_domain'

class NambuUrl
  def NambuUrl.valid?(url)
    begin
      uri = URI.parse(url)
    rescue Exception => e then
      RAILS_DEFAULT_LOGGER.info "NambuUrl(): URL Validation FAILED: Bad URL [#{url}]"
      return false
    end
    return true if uri.host
    return false
  end
  
  def NambuUrl.domain(url)
    begin
      uri = URI.parse(url)
    rescue Exception => e then
      RAILS_DEFAULT_LOGGER.info "NambuUrl(): URI Parse FAILED [#{url}]. Invalid?"
      return String.new
    end
    return NambuUrl.get_domainname(uri.host) if uri.host
  end


  def NambuUrl.get_domainname(hostname)
    tlds = Rails.cache.fetch("tlds", :expires_in => 24.hours) { TopLevelDomain.all }
    rval = String.new
    for tld in tlds
      if hostname.include?(".#{tld.tld}")
        rval = NambuUrl.extract_domain(tld.tld.split(/\./).length, hostname)
        break
      end
    end
    rval = NambuUrl.extract_domain(1, hostname) if rval.empty?
    return rval
  end
  def NambuUrl.extract_domain(tldsize, hostname)
    rval = String.new
    nameparts = hostname.split(/\./)
    if (tldsize + 1) == nameparts.length
      rval = hostname
    else
      i = 0
      for part in nameparts
        if i >= (nameparts.length - tldsize - 1)
          if rval.empty?
            rval  = part
          else rval += ".#{part}" end
        end
        i += 1
      end
    end
    return rval
  end
end
