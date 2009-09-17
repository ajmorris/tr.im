##
# NCTwitter is a class for getting stuff to and from Twitter via their API. It will do the required task, and return the 
# parsed JSON response. It uses JSON exclusively. It will throw one of the exceptions below if there is an error condition.
#
# Possible error messages from Twitter API:
# -- 200 OK. Everything Went Awesome.
# -- 304 Not Modified. [There was no new data to return.]
# -- 400 Bad Request. [Your request is invalid, with an error message. Error for the rate limit.]
# -- 401 Not Authorized. [Either you need to provide authentication credentials, or the credentials provided aren't valid.]
# -- 403 Forbidden. [We understand your request, but are refusing to fulfill it.]
# -- 404 Not Found. [Either you're requesting an invalid URI or the resource doesn't exist.]
# -- 500 Internal Server Error [We did something wrong.]
# -- 502 Bad Gateway [Returned if Twitter is down or being upgraded.]
# -- 503 Service Unavailable [The Twitter servers are up, but are overloaded with requests.]
#
# For each of use NCTwitter() will collapse these numerous error conditions to Ruby Exceptions of three types:
#   NCNotAuthorized
#   NCRateLimited
#   NCGeneralFailure
#
# So by extension if none of exceptions are not caught, you can assume all is good, and go with the JSON
# parsed response data.
##

require 'net/http'
require 'uri'
require 'rubygems'
require 'json'

class NCTwitter
  attr_accessor :source, :username, :password

  def initialize(hash)
    hash.each do |key, value|
      self.instance_variable_set("@#{key}", value)
      self.class.send(:define_method, key, proc { self.instance_variable_get("@#{key}") })
      self.class.send(:define_method, "#{key}=", proc {|value| self.instance_variable_set("@#{key}", value) })
    end
    @source = "nambu" if not @source
    @username = String.new if not @username
    @password = String.new if not @password
  end

  ## General Twitter API methods for determing Twitter account status. This includes username/password
  ## vertification and API status.
  
  def verified?
    retcode = 200
    begin
      res = submit_network_request("/account/verify_credentials.json")
      return true if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.verified?()", e)
    else
      throw_nc_exception("NCTwitter.verified?()", retcode) end
  end
  def api_status
    retcode = 200
    begin
      res = submit_network_request("/account/rate_limit_status.json")
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.api_status()", e)
    else
      throw_nc_exception("NCTwitter.api_status()", retcode) end
  end
  
  def test
    retcode = 200
    begin
      res = submit_network_request("/help/test.json")
      return res.body if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.test()", e)
    else
      throw_nc_exception("NCTwitter.test()", retcode) end
  end
  
  def update_profile(name = nil, email = nil, url = nil, location = nil, description = nil)
    retcode = 200
    begin
      uri = URI.parse("http://twitter.com/account/update_profile.json")
      req = Net::HTTP::Post.new(uri.path)
      req.basic_auth @username, @password
      args = {}
      args["name"] = name unless name.blank?
      args["email"] = email unless email.blank?
      args["url"] = url unless url.blank?
      args["location"] = location unless location.blank?
      args["description"] = description unless description.blank?
      
      req.set_form_data(args.merge({"source" => @source}))
      res = Net::HTTP.new(uri.host, uri.port).start {|http| http.request(req) }
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.update_profile()", e)
    else
      throw_nc_exception("NCTwitter.update_profile()", retcode) end    
  end
  
  ## Twitter timeline methods that all grab a list of tweets for various situations, from general
  ## public to "other" users.
  
  def timeline_public
    retcode = 200
    begin
      res = submit_network_request("/statuses/public_timeline.json")
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.timeline_public?()", e)
    else
      throw_nc_exception("NCTwitter.timeline_public?()", retcode) end
  end
  def timeline_followings(since_id = 1, count = 250)
    retcode = 200
    begin
      res = submit_network_request("/statuses/friends_timeline.json?since_id=#{since_id}&count=#{count}")
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.timeline_followings()", e)
    else
      throw_nc_exception("NCTwitter.timeline_followings()", retcode) end
  end
  def timeline_for_login(since_id = 1, count = 250)
    retcode = 200
    begin
      res = submit_network_request("/statuses/user_timeline.json?since_id=#{since_id}&count=#{count}")
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.timeline_for_login()", e)
    else
      throw_nc_exception("NCTwitter.timeline_for_login()", retcode) end
  end
  def timeline_for_name(name, since_id = 1, count = 250)
    retcode = 200
    begin
      res = submit_network_request("/statuses/user_timeline/#{name}.json?since_id=#{since_id}&count=#{count}")
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.timeline_for_name()", e)
    else
      throw_nc_exception("NCTwitter.timeline_for_name()", retcode) end
  end
  def timeline_replies_for_login(since_id = 1, count = 250)
    retcode = 200
    begin
      res = submit_network_request("/statuses/replies.json?since_id=#{since_id}&count=#{count}")
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.timeline_replies_for_login()", e)
    else
      throw_nc_exception("NCTwitter.timeline_replies_for_login()", retcode) end
  end

  def timeline_direct_in(since_id = 1, count = 250)
    retcode = 200
    begin
      res = submit_network_request("/direct_messages.json?since_id=#{since_id}&count=#{count}")
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.timeline_direct_in()", e)
    else
      throw_nc_exception("NCTwitter.timeline_direct_in()", retcode) end
  end
  def timeline_direct_out(since_id = 1, count = 250)
    retcode = 200
    begin
      res = submit_network_request("/direct_messages/sent.json?since_id=#{since_id}&count=#{count}")
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.timeline_direct_out()", e)
    else
      throw_nc_exception("NCTwitter.timeline_direct_out()", retcode) end
  end
  
  
  ## get_single_tweet() is for getting a specific status ID if you have the unique ID for the status
  ## at Twitter.

  def get_single_tweet(status_id)
    retcode = 200
    begin
      res = submit_network_request("/statuses/show/#{status_id}.json")
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.get_single_tweet()", e)
    else
      throw_nc_exception("NCTwitter.get_single_tweet()", retcode) end
  end


  ## Two methods for sending new updates to Twitter, public updates and direct messages, for the
  ## authenticated user.

  def submit_status_update(status_text)
    RAILS_DEFAULT_LOGGER.info "NCTwitter(): Tweet with Source [#{@source}]"
    retcode = 200
    begin
      url = URI.parse("http://twitter.com/statuses/update.json")
      req = Net::HTTP::Post.new(url.path)
      req.basic_auth @username, @password
      req.set_form_data({"status" => status_text, "source" => @source})
      res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.submit_status_update()", e)
    else
      throw_nc_exception("NCTwitter.submit_status_update()", retcode) end
  end
  def submit_direct_message(recipient, status_text)
    RAILS_DEFAULT_LOGGER.info "NCTwitter(): DM with Source [#{@source}]"
    retcode = 200
    begin
      url = URI.parse("http://twitter.com/direct_messages/new.json")
      req = Net::HTTP::Post.new(url.path)
      req.basic_auth @username, @password
      req.set_form_data({"user" => recipient, "text" => status_text, "source" => @source})
      res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.submit_direct_message()", e)
    else
      throw_nc_exception("NCTwitter.submit_direct_message()", retcode) end
  end
  
  
  ## delete_direct_message() is for deleting a direct message specified in ID
  
  def delete_direct_message(message_id)
    retcode = 200
    begin
      url = URI.parse("http://twitter.com/direct_messages/destroy/#{message_id}.json")
      req = Net::HTTP::Post.new(url.path)
      req.basic_auth @username, @password
      res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.delete_direct_message()", e)
    else
      throw_nc_exception("NCTwitter.delete_direct_message()", retcode) end
  end
  
  ## delete_status() is for deleting a specific status ID if you have the unique ID for the status
  ## at Twitter.
  
  def delete_status(status_id)
    retcode = 200
    begin
      url = URI.parse("http://twitter.com/statuses/destroy/#{status_id}.json")
      req = Net::HTTP::Post.new(url.path)
      req.basic_auth @username, @password
      res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.delete_status()", e)
    else
      throw_nc_exception("NCTwitter.delete_status()", retcode) end
  end
  
  
  def add_friend(user_id, follow = false)
    retcode = 200
    begin
      url = URI.parse("http://twitter.com/friendships/create/#{user_id}.json#{follow ? '?follow=true' : ''}")
      req = Net::HTTP::Post.new(url.path)
      req.basic_auth @username, @password
      res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.add_friend()", e)
    else
      throw_nc_exception("NCTwitter.add_friend()", retcode) end
  end  
  
  def delete_friend(user_id)
    retcode = 200
    begin
      url = URI.parse("http://twitter.com/friendships/destroy/#{user_id}.json")
      req = Net::HTTP::Post.new(url.path)
      req.basic_auth @username, @password
      res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.delete_friend()", e)
    else
      throw_nc_exception("NCTwitter.delete_friend()", retcode) end
  end
  
  def are_users_friends(user_a, user_b)
    retcode = 200
    begin
      res = submit_network_request("/friendships/exists.json?user_a=#{user_a}&user_b=#{user_b}")
      # this api doesn't return json but plain text 'true' or 'false'
      return (res.body == 'true') if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.are_users_friends()", e)
    else
      throw_nc_exception("NCTwitter.are_users_friends()", retcode) end    
  end

  ## get_friends() is for getting up to 100 of the authenticating user's friends who have most recently updated, 
  ## each with current status inline. "user_id" is The Twitter ID or screen name of the user for whom to
  ## request a list of friends.
  
  def get_friends(user_id = nil, page = 1)
    retcode = 200
    begin
      res = submit_network_request("/statuses/friends#{ user_id.nil? ? '' : '/' + user_id.to_s }.json?page=#{page}")
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.get_friends()", e)
    else
      throw_nc_exception("NCTwitter.get_friends()", retcode) end
  end
  
  ## get_followers() is for getting up to 100 of the authenticating user's followers, each with current status inline.
  ## user_id: The ID or screen name of the user for whom to request a list of friends
  
  def get_followers(user_id = nil, page = 1)
    retcode = 200
    begin
      res = submit_network_request("/statuses/followers#{ user_id.nil? ? '' : '/' + user_id.to_s }.json?page=#{page}")
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.get_followers()", e)
    else
      throw_nc_exception("NCTwitter.get_followers()", retcode) end
  end

  def follow_user(user_id)
    retcode = 200
    begin
      url = URI.parse("http://twitter.com/friendships/create/#{user_id}.json")
      req = Net::HTTP::Post.new(url.path)
      req.basic_auth @username, @password
      res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.follow_user()", e)
    else
      throw_nc_exception("NCTwitter.follow_user()", retcode) end
  end  
  
  def unfollow_user(user_id)
    RAILS_DEFAULT_LOGGER.info "NCTwitter(): Tweet with Source [#{@source}]"
    retcode = 200
    begin
      url = URI.parse("http://twitter.com/friendships/destroy/#{user_id}.json")
      req = Net::HTTP::Post.new(url.path)
      req.basic_auth @username, @password
      res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.leave_user()", e)
    else
      throw_nc_exception("NCTwitter.leave_user()", retcode) end
  end
  
  def block_user(user_id)
    retcode = 200
    begin
      url = URI.parse("http://twitter.com/blocks/create/#{user_id}.json")
      req = Net::HTTP::Post.new(url.path)
      req.basic_auth @username, @password
      res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.block_user()", e)
    else
      throw_nc_exception("NCTwitter.block_user()", retcode) end
  end  
  
  def unblock_user(user_id)
    retcode = 200
    begin
      url = URI.parse("http://twitter.com/blocks/destroy/#{user_id}.json")
      req = Net::HTTP::Post.new(url.path)
      req.basic_auth @username, @password
      res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.unblock_user()", e)
    else
      throw_nc_exception("NCTwitter.unblock_user()", retcode) end
  end
  
  ## get_favorites() is for getting 20 most recent favorite statues for the authenticating user or user specified by the id
  ## user_id: The ID or screen name of the user for whom to request a list of friends
  
  def get_favorites(user_id = nil, page = 1)
    retcode = 200
    begin
      res = submit_network_request("/favorites#{ user_id.nil? ? '' : '/' + user_id.to_s }.json?page=#{page}")
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.get_favorites()", e)
    else
      throw_nc_exception("NCTwitter.get_favorites()", retcode) end
  end
  
  def add_favorite(status_id)
    retcode = 200
    begin
      url = URI.parse("http://twitter.com/favorites/create/#{status_id}.json")
      req = Net::HTTP::Post.new(url.path)
      req.basic_auth @username, @password
      res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.add_favorite()", e)
    else
      throw_nc_exception("NCTwitter.add_favorite()", retcode) end
  end  
  
  def delete_favorite(status_id)
    retcode = 200
    begin
      url = URI.parse("http://twitter.com/favorites/destroy/#{status_id}.json")
      req = Net::HTTP::Post.new(url.path)
      req.basic_auth @username, @password
      res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.delete_favorite()", e)
    else
      throw_nc_exception("NCTwitter.delete_favorite()", retcode) end
  end
  
  ## get_user is for getting extended information of a given user, specified by ID or screen name
  
  def get_user(user_id)
    retcode = 200
    begin
      res = submit_network_request("/users/show/#{user_id}.json")
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.get_user()", e)
    else
      throw_nc_exception("NCTwitter.get_user()", retcode) end    
  end
  
  ## get_user_by_email is for getting extended information of a given user, specified by email
  
  def get_user_by_email(email)
    retcode = 200
    begin
      res = submit_network_request("/users/show.json?email=#{email}")
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.get_user_by_email()", e)
    else
      throw_nc_exception("NCTwitter.get_user_by_email()", retcode) end    
  end
  
  ## get_friends_ids is for getting an array of numeric IDs for every user the specified user is following.
  ## user_id: The ID or screen_name of the user to retrieve the friends ID list for.

  def get_friends_ids(user_id = nil)
    retcode = 200
    begin
      res = submit_network_request("/friends/ids#{ user_id.nil? ? '' : '/' + user_id.to_s }.json")
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.get_followers_ids()", e)
    else
      throw_nc_exception("NCTwitter.get_followers_ids()", retcode) end    
  end
  
  ## get_followers_ids is for getting an array of numeric IDs for every user the specified user is followed by.
  ## user_id: The ID or screen_name of the user to retrieve the friends ID list for.
  
  def get_followers_ids(user_id = nil)
    retcode = 200
    begin
      res = submit_network_request("/followers/ids#{ user_id.nil? ? '' : '/' + user_id.to_s }.json")
      return JSON.parse(res.body) if res.code.to_i == 200
      retcode = res.code.to_i
    rescue Exception => e
      throw_general_exception("NCTwitter.get_followers_ids()", e)
    else
      throw_nc_exception("NCTwitter.get_followers_ids()", retcode) end    
  end
  
  
  private
  def submit_network_request(request_path)
    Net::HTTP.start("twitter.com") {|http|
      req = Net::HTTP::Get.new(request_path)
      req.basic_auth @username, @password if (not @username.blank?) && (not @password.blank?)
      return http.request(req)
    }
  end

  def throw_nc_exception(method, code)
    case code
    when 400
      RAILS_DEFAULT_LOGGER.info "#{method}: Twitter Failure [CODE 400]"
      raise NCRateLimited
    when 401
      RAILS_DEFAULT_LOGGER.info "#{method}: Twitter Failure [CODE 401]"
      raise NCNotAuthorized
    else
      RAILS_DEFAULT_LOGGER.info "#{method}: GENERAL Twitter Failure [CODE #{code}]"
      raise NCGeneralFailure end
  end
  def throw_general_exception(method, e)
    RAILS_DEFAULT_LOGGER.info ".. #{method}: Fatal Exception Rescued [#{e.to_s}]."
    RAILS_DEFAULT_LOGGER.info e.backtrace.join("\n")
    raise NCGeneralFailure
  end
end
