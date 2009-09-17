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

class Account::PreferencesController < ApplicationController
  before_filter :has_session_with_redirect?
  before_filter :ajax?, :only => [ :update ]
  before_filter :set_url_sorts, :only => [ :edit ]
  before_filter :set_url_returns, :only => [ :edit ]

  def edit
    @pt = "#{WEBSITE_CONFIG['website_domain']} | Account | Preferences"
    @sb = "preferences"
    @tab = "account"
    @tagline = "Account Preferences"
  end
  def update
    if TrimPreferencesUser.exists?({ :user_id => @user.id })
      tpu = TrimPreferencesUser.first(:conditions => { :user_id => @user.id })
    else
      tpu = TrimPreferencesUser.create!(:user_id => @user.id, :prefs_id => @trim_preferences.id)
    end
    @trim_preferences = tpu.preferences
    @trim_preferences.update_attributes(params[:trim_preferences])
    @trim_preferences[:urlsppage] = TrimsList::MAX_URLS_IN_LIST if @trim_preferences.urlsppage > TrimsList::MAX_URLS_IN_LIST
    @trim_preferences.save!
  end
end
