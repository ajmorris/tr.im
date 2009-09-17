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

module TrimHelpers
  protected
  def word_trim
    "<span>tr</span><span class=\"trimdot\">.</span><span>im</span>"
  end
  def word_trimmed
    "<span>tr</span><span class=\"trimdot\">.</span><span>immed</span>"
  end
  def word_trimit
    "<span>tr</span><span class=\"trimdot\">.</span><span>im</span><span class=\"trimdot\">.</span>it"
  end
  def word_trimming
    "<span>tr</span><span class=\"trimdot\">.</span><span>imming</span>"
  end

  def word_picim
    "<span>pic</span><span class=\"trimdot\">.</span><span>im</span>"
  end

  ## For tr.im configured network IDs we have a set of methods for getting to known URLs as it pertains to their 
  ## timelines or tweets.

  def get_tweeter_username(user_account_id)
    return nil
  end
  def get_tweeter_link(user_account_id)
    return nil
  end
  def get_tweet_link(user_account_id, tweet_id)
    return nil
  end

  def get_submitter_link(network_id, username)
    network = get_cached_network(network_id)
    case network_id
    when Network::TWITTER
      return "#{network.url}/#{username}" end
  end
  def get_submission_link(network_id, username, tweet_id)
    network = get_cached_network(network_id)
    case network_id
    when Network::TWITTER
      url = "#{network.url}/#{username}/status/#{tweet_id}"
    end
    return "<a href=\"#{url}\">#{username}</a> to <a href=\"#{network.url}\" target=\"_blank\">#{network.name}</a>"
  end
end
