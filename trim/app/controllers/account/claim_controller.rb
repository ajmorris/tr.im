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

class Account::ClaimController < ApplicationController
  before_filter :has_session_with_redirect?
  before_filter :ajax?, :only => [ :update, :on, :off ]
  before_filter :set_claim_oauth, :only => [ :on, :off ]

  def index
    @pt = "#{WEBSITE_CONFIG['website_domain']} | Account | Claim URLs"
    @sb = "claims"
    @tab = "account"
    @tagline = "Claim URLs"
  end
  
  def on
    if @claim_oauth && @claim_oauth.owned_by_user_id?(@user.id) && (not TrimClaimant.exists?({ :user_id => @user.id, :oauth_id => @claim_oauth }))
      TrimClaimant.create!(:user_id => @user.id, :oauth_id => @claim_oauth.id) 
    end
  end
  def off
    if @claim_oauth && @claim_oauth.owned_by_user_id?(@user.id) && TrimClaimant.exists?({ :user_id => @user.id, :oauth_id => @claim_oauth })
      TrimClaimant.destroy(TrimClaimant.first(:conditions => { :user_id => @user.id, :oauth_id => @claim_oauth }).id)
    end
  end
  
  private
  def set_claim_oauth
    conditions = { :website_id => WEBSITE_CONFIG['website_id'], :status => NetworkOAuth::STATUS_DONE, :username => params[:username] }
    @claim_oauth = nil
    @claim_oauth = NetworkOAuth.first(:conditions => conditions) if params[:username]
    return true
  end
end
