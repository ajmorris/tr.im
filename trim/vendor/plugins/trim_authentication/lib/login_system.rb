##
# Written by Eric Woodward, ejw@nambu.com.
# Copyright 2008-2009. The Nambu Network Inc. All Rights Reserved.
##

module LoginSystem
  ## The Nambu LoginSystem has two sections: 1) to permit login with a nambu account stored in the "users"
  ## table for one of its network websites; and 2) to enter a remote network username and password 
  ## combination that can be verified against a remote API and then used to lookup a nambu account.

  ## These first two tables will help the caller determine the state of any session that may exist,
  ## and what do with the result.
  
  protected
  def user_account_exists?(website_id, login, email)
    user_login_exists?(website_id, login) || user_email_exists?(website_id, email)
  end
  def user_login_exists?(website_id, login)
    User.exists?({ :website_id => website_id, :login => login.downcase })
  end
  def user_email_exists?(website_id, email)
    User.exists?({ :website_id => website_id, :email => email.downcase })      
  end

  def has_session?
    return true if @user
    user_id = session[:user].id if session[:user]
    user_id = session[:user_id] if session[:user_id]
    if user_id && (not @user) && User.exists?(user_id)
      @user = User.find(user_id)
      session[:user] = nil
      session[:user_id] = @user.id
      return true
    end
    return false
  end
  def has_session_with_redirect?(do_redirect = true, redirect_page = "/login/")
    return true if has_session?
    if do_redirect
      redirect_to redirect_page
    else
      return false end
  end

  ## These methods set various instance variables that are required for almost all Nambu website
  ## Rails requests.

  def set_timezone
    Time.zone = @user.time_zone if has_session?
  end
  def set_user_login
    @user_login = String.new
    @user_login = cookies[:USERLOGIN] if cookies[:USERLOGIN]
  end
  def reset_user_login(new_login)
    cookies[:USERLOGIN] = { :value => new_login, :expires => cookie_expiry }
  end

  ## The central method for this module, to attempt a login again the Nambu users accounts
  ## table.

  def start_session(website_id, login, password, cookie_expiry = 365.days.from_now)
    if (not login.blank?) && (not password.blank?)
      case request.method
      when :post
        ss_login = login.downcase
        qs = "website_id = ? AND (login = ? OR email = ?)"
        if User.exists?([qs, website_id, ss_login, ss_login])
          @user = User.first(:conditions => [qs, website_id, ss_login, ss_login])
          if @user.valid_password?(password)
            session[:user_id] = @user.id
            cookies[:USERLOGIN] = { :value => ss_login, :expires => cookie_expiry }
            set_user_login_record
            return true
          else
            @user = nil end
        end
      else
        set_user_login end
    end
    return false
  end
  def end_session
    session[:user] = nil if session[:user]
    session[:user_id] = nil if session[:user_id]
    return true
  end

  ## Methods to record user logins as they occur, as called by the website itself, and to update
  ## the users table with the last time we saw the user.

  def set_user_login_record
    user_login = UserLogin.create!(:user_id => @user.id, :ip_address => @remote_ip)
  end
  def set_user_last_seen
    if has_session?
      if @user.last_seen.to_date != (Time.now).to_date
        @user[:last_ip] = @remote_ip
        @user[:last_seen] = Time.now
        @user.save(false)
        RAILS_DEFAULT_LOGGER.info "RECORDED Last Seen IP Address [#{@remote_ip}] for USER [#{@user.login}]"
      else
        RAILS_DEFAULT_LOGGER.info "Last Seen UP TO DATE for USER [#{@user.login}]" end
    end
  end
end
