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

class TopTrims
  attr_reader :user_id, :maximum, :trims, :trims_by_clicks

  DEFAULT_MAXIMUM = 20

  def initialize(user_id, maximum = DEFAULT_MAXIMUM)
    @user_id = user_id
    @maximum = maximum
    @trims, @trims_by_clicks = Array.new, Array.new

    set_trims
  end
  
  def length
    @trims.length
  end
  def has_trims?
    (not @trims.empty?)
  end
  
  protected
  def set_trims
    @trims = TrimUrl.all(:select => "tu.*", :from => "trim_urls tu, trim_user_urls tuu",
                         :order => "tu.id DESC",
                         :limit => self.maximum,
                         :conditions => ["tu.id = tuu.trim_url_id AND tuu.user_id = #{self.user_id} AND tu.clicks > 0"])
    @trims_by_clicks = @trims.sort {|x,y| y.clicks <=> x.clicks }
  end
end
