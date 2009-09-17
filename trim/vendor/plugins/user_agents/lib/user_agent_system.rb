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

require 'user_agent'

module UserAgentSystem
  protected
  def set_user_agent
    RAILS_DEFAULT_LOGGER.info "Processing User Agent in Rails Request: [#{request.user_agent}]"
    if not request.user_agent.blank?
      count = 0
      while count <= 5
        count += 1
        begin
          tmps = request.user_agent
          tmps = request.user_agent[0, 254] if request.user_agent.length > 255
          if UserAgent.exists?({ :details => tmps })
            @user_agent = UserAgent.first(:conditions => { :details => tmps })
          else
            @user_agent = UserAgent.create!(:details => tmps)
          end
          break
        rescue ActiveRecord::StatementInvalid => e                            ## MySQL Insert Failed?
          RAILS_DEFAULT_LOGGER.info "MSQL Statement [FAILED] for User Agent Insertion?"
        end
      end
    end
    @user_agent = UserAgent.find(UserAgent::UNKNOWN) if @user_agent.blank?
    RAILS_DEFAULT_LOGGER.info "User Agent SET: [#{@user_agent.id}]"
    RAILS_DEFAULT_LOGGER.info "User Agent SENT: [#{request.user_agent}]"
  end
  def get_cached_agent(agent_id)
    Rails.cache.fetch("user_agent_#{agent_id}", :expires_in => 30.minutes) { UserAgent.find(agent_id, :include => [ :platform, :browser ]) }
  end
end
