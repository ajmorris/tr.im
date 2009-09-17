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

module PasswordSystem
  protected
  def located_account_for_reset?(utag)
    utag.downcase!
    if User.exists?(["login = ? OR email = ?", utag, utag])
      @user = User.first(:conditions => ["login = ? OR email = ?", utag, utag])
      return true
    end
    false
  end
  def set_interim_password_with_reset(code)
    @user_reset = get_user_reset(code)

    interim = User.find(@user_reset.user_id)
    interim[:password] = params[:interim][:password]
    interim.save(false)
    establish_auto_session(interim.id, interim.login)

    @user_reset[:status] = "USED"
    @user_reset.save!
    session[:user_reset_code] = nil
  end


  def user_reset_exists?(code)
    UserReset.exists?({ :code => code })
  end
  def user_reset_valid?(code)
    UserReset.exists?(["code = ? AND status != ? AND created_at >= ?", code, UserReset::STATUS_USED, 1.day.ago])
  end
  
  def get_user_reset(code)
    return UserReset.first(:conditions => { :code => code }) if user_reset_exists?(code)
    return nil
  end
  def set_user_reset(user_id)
    @user_reset = UserReset.create!(:user_id => @user.id, :code => TrimObject.get_random_code(32))
  end


  def process_user_reset(code)
    @user_reset = get_user_reset(code)
    @has_user_reset = true
    session[:user_reset_code] = code
    expire_user_reset
  end
  def expire_user_reset
    UserReset.transaction do
      @user_reset[:status] = UserReset::STATUS_USED
      @user_reset.save
    end
  end
end
