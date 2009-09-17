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

module ApplicationHelper
  def logo_image_path
    return "/images/main/logo_beta.jpg" if request.env['HTTP_HOST'].include?("beta")
    return "/images/main/logo.jpg"
  end

  def get_title_urlslist
    base = "Your #{word_trimmed} URLs"
    return base if @user_urls_total < @trim_preferences.urls_per_page
    return base << " #{@user_urls.offset + 1} - #{@user_urls.offset + @user_urls.length} of #{number_with_delimiter(@user_urls_total)}"
  end
  def get_title_urlscharts
    if @user_urls_total > @trim_preferences.urls_per_page
      return "Performance of URLs #{@user_urls.offset + 1} - #{@user_urls.offset + @user_urls.length} of #{@user_urls_total}"
    else
      return "Performance of Your one #{word_trim} URL" if @user_urls.length == 1
      return "Performance of Your #{@user_urls.length} #{word_trim} URLs" end
  end

  def get_url_statslink(trim_url, shortening)
    href = { :href => trim_stats_url(:surl => shortening.surl) }
    href.merge!({ :target => "_blank" }) if @trim_preferences.new_statistics_page?
    return href
  end
  def get_url_label(url_destination, trim_url, length = 68, domain = false)
    if trim_url.has_title?
      return trim_url.title
    else
      if domain
        return url_destination.domain(@tlds)
      else
        if url_destination.url.length > length
          return "#{url_destination.url[0, length - 1]}[...]"
        else
          return url_destination.url end end
    end
  end
  def get_url_row_highlight(counter)
    return { "onmouseover" => "this.className='urlhighlight'", "onmouseout" => "this.className='urldatanormal'" } if (counter % 2) == 0
    return { "class" => "urldatadark", "onmouseover" => "this.className='urlhighlight'", "onmouseout" => "this.className='urldatadark'" }
  end
end
