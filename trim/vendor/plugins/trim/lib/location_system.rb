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

require 'trim_country'

module LocationSystem
  protected
  def set_countries
    @countries = Rails.cache.fetch("countries", :expires_in => 12.hours) { TrimCountry.all(:order => "name") }
  end
  def get_cached_country(country_id)
    @countries.detect {|c| c.id == country_id }
  end

  def set_ipaddress
    @remote_ip = request.remote_ip
    logger.info "RAILS REQUEST IP: #{@remote_ip}"
    logger.info "X_FORWARDED_FOR: #{request.env['X_FORWARDED_FOR']}" if request.env['X_FORWARDED_FOR']
    logger.info "HTTP_X_FORWARDED_FOR: #{request.env['HTTP_X_FORWARDED_FOR']}" if request.env['HTTP_X_FORWARDED_FOR']
    if request.env['HTTP_X_FORWARDED_FOR']
      tmpa = request.env['HTTP_X_FORWARDED_FOR'].split(',')
      @remote_ip = tmpa[0].strip
    end
    @remote_ip = "64.46.11.227" if @remote_ip == "127.0.0.1"
    logger.info "IP ADDRESS SET: [#{@remote_ip}]"
  end
  
  def set_iplocation
    locator = IPLocator.new(:ip_address => VL_getip)
    if not session[:iplocation_timestamp] || session[:iplocation_timestamp] < 5.hours.ago || params[:test_ipl]
      session[:iplocation] = locator.ip_location
      session[:iplocation_timestamp] = Time::now
    end
    if country = TrimCountry.find(:first, :conditions => ["code = ?", session[:iplocation].country_code])
      session[:iplocation_country] = country
    else
      session[:iplocation_country] = TrimCountry.find(255) end
  end
  def set_ipcountry
    locator = IPLocator.new(:ip_address => VL_getip)
    if not session[:ipcountry_timestamp] || session[:ipcountry_timestamp] < 5.hours.ago || params[:test_ipl]
      session[:ipcountry] = locator.ip_country
      session[:ipcountry_timestamp] = Time::now
    end
    if country = TrimCountry.find(:first, :conditions => ["code = ?", session[:ipcountry].country_code])
      session[:ipcountry_country] = country
    else
      session[:ipcountry_country] = TrimCountry.find(255) end
  end

  def ip_from_ipnum(ipnum)
    tmps = String.new
    tmps << ((ipnum / 16777216) % 256).to_s + "."
    tmps << ((ipnum / 65536   ) % 256).to_s + "."
    tmps << ((ipnum / 256     ) % 256).to_s + "."
    tmps << ((ipnum           ) % 256).to_s
    return(tmps)
  end
  def ip_to_ipnum(ip)
    tmpa = ip.split('.')
    return ((16777216 * tmpa[0].to_i) + (65536 * tmpa[1].to_i) + (256 * tmpa[2].to_i) + tmpa[3].to_i)
  end

  private
  def VL_getip
    set_ipaddress unless @remote_ip
    @remote_ip == "127.0.0.1" ? "64.46.11.227" : @remote_ip
  end
end
