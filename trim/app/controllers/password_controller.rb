##
# Written by Eric Woodward, ejw@nambu.com.
# Copyright 2008-2009. The Nambu Network Inc. All Rights Reserved.
##

class PasswordController < ApplicationController
  before_filter :ajax?, :only => [ :send, :update ]

  def lost
    @pt = "#{WEBSITE_CONFIG['website_domain']} | Lost Password Reset"
    @tab = "none"
    @tagline = "Lost Password Reset"
  end
  def deliver
    if params[:user] && (not params[:user][:account].blank?)

      if located_account_for_reset?(params[:user][:account])   
        set_user_reset(@user.id)
        send_reset_email({ "to" => @user.email, "login" => @user.login, "code" => @user_reset.code })
        render :update do |page|
          page.replace_html 'content_lostpwd', :partial => "result_pwd" end

      else
        render :update do |page|
          page << "$('user_account').focus()"
          page.replace_html 'errors_lostpwd', t(:no_account, :scope => :errors) end end

    else
      render :update do |page|
        page << "$('user_account').focus()"
        page.replace_html 'errors_lostpwd', t(:no_account_data, :scope => :errors) end end
  end
  
  def reset
    @pt = "#{WEBSITE_CONFIG['website_domain']} | Lost Password Reset"
    @tab = "none"
    @tagline = "Lost Password Reset"
    @has_user_reset = false
    if params[:id] && params[:id].length > UserReset::MINIMUM_LENGTH
      process_user_reset(params[:id]) if user_reset_valid?(params[:id])
    else
      redirect_to WEBSITE_CONFIG['website_url'] end
  end

  def update
    if (not params[:interim][:password].blank?) && (not params[:interim][:password_confirm].blank?)
      if params[:interim][:password] == params[:interim][:password_confirm]
        if params[:interim][:password].length >= User::MINIMUM_PASSWORD_LENGTH

          if user_reset_exists?(session[:user_reset_code])
            set_interim_password_with_reset(session[:user_reset_code])
            render :update do |page|
              page << "$('interim_password').focus()"
              page.replace_html 'content_resetpwd', :partial => "result_reset" end
          else
            render :update do |page|
              page << "$('interim_password').focus()"
              page.replace_html 'errors_reset', t(:reset_security, :scope => :errors) end end

        else
          render :update do |page|
            page << "$('interim_password').focus()"
            page.replace_html 'errors_reset', t(:reset_minimum, :scope => :errors) end end
      else
        render :update do |page|
          page << "$('interim_password').focus()"
          page.replace_html 'errors_reset', t(:reset_nomatch, :scope => :errors) end end
    else
      render :update do |page|
        page << "$('interim_password').focus()"
        page.replace_html 'errors_reset', t(:reset_nomatch, :scope => :errors)  end end
  end
  
  protected
  def send_reset_email(values)
    spawn do
      case WEBSITE_CONFIG['website_id']
      when Website::PICIM
        email = TrimEmail.find(TrimEmail::RESET_PASSWORD_PICIM)
      else
        email = TrimEmail.find(TrimEmail::RESET_PASSWORD_TRIM)
      end
      email.deliver(values)
    end
  end
end
