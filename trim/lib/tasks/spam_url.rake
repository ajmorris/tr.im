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
# Script to take a tr.im URL path, sich as "AbCd" and disable it as a URL used in a spam email, or undesirable activity
# or badness.
#   Example: rake ops:spam_url TP=AbCd
#
# We detach the URL from the user's account or session so they can no longer access its statistics via the website.
# We stop short of doing anything do the user account itself, or other URLs it may have for fear of stomping on the
# innocent and creating support headcaches.
#
# We disable the domain name in the destination URL as well for all future tr.imming. We use a TLD map included with
# tr.im to ensure we get domain.com, not just www.domain.com, but don't cut off co.uk for bbc.co.uk, for example.
##

namespace :ops do
  desc "Deactivate a tr.im URL as spam, and target the destination domain name as well"
  task :spam_url => :environment do

    tlds = TopLevelDomain.all
    if UrlShortening.exists?({ :shortener_id => UrlShortener::ID_TRIM, :surl => ENV['URL'] })
      shortening = UrlShortening.first(:conditions => { :shortener_id => UrlShortener::ID_TRIM, :surl => ENV['URL'] })
      trim_url = TrimUrl.first(:conditions => { :shortened_id => shortening.id })

      trim_url[:return_id] = UrlReturn::SPAM
      trim_url.save
      TrimUserUrl.delete_all("trim_url_id = #{trim_url.id}")
      TrimSessionUrl.delete_all("trim_url_id = #{trim_url.id}")

      domain = trim_url.shortening.url_destination.domain(tlds)
      UrlSpamDomain.create!(:domain => domain) unless UrlSpamDomain.exists?({ :domain => domain })

      puts "SPAM TR.IM: #{trim_url.shortening.surl}"
      puts "SPAM URL: #{trim_url.shortening.url_destination.url}"
      puts "SPAM DOMAIN TERMINATED: #{domain}"

    else puts "Specified tr.im URL [#{ENV['URL']}] does not exist." end
  end
end
