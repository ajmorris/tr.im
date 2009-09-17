##
# Written by Eric Woodward, ejw@nambu.com.
# Copyright 2008-2009. The Nambu Network Inc. All Rights Reserved.
##

class LoginController < ApplicationController
  before_filter :ajax?, :only => [ :login ]
  before_filter :set_user_login, :only => [ :index ]

  def index
    @pt = "#{WEBSITE_CONFIG['website_domain']} | Account Login"
    @tab = "account"
    @tagline = "#{WEBSITE_CONFIG['website_domain']} Login"
  end

  def login
    if params[:user] && (not params[:user][:login].blank?) && (not params[:user][:password].blank?)
      if start_session(WEBSITE_CONFIG['website_id'], params[:user][:login], params[:user][:password])
        set_session_oauths_as_user_oauths
        render :update do |page|
          page.redirect_to account_url end
      else
        render :update do |page|
          page << "$('errors_login').update('#{t(:login_failed, :scope => :errors)}')"
          page << "$('user_password').focus()" end end
    else
      render :update do |page|
        page.replace_html 'errors_login', t(:login_incomplete, :scope => :errors)
        page << "$('user_password').focus()" end end
  end
  def logout
    flash[:notice] = t(:logout, :scope => :notices)
    end_session
    redirect_to url_for(:controller => "login")
  end
end
