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

class TrimEmail < ActiveRecord::Base
  set_table_name "emails"
  
  belongs_to :website
  
  SIGNUP_TRIM = 1
  REPORT_SPAM = 2
  RESET_PASSWORD_TRIM = 3

  SIGNUP_PICIM = 10
  REPORT_PORN = 11
  RESET_PASSWORD_PICIM = 12
  
  TEMPLATE_ROOT = "#{RAILS_ROOT}/../trim/vendor/plugins/trim"

  def deliver(values)
    RAILS_DEFAULT_LOGGER.info ".. Sending WITH -> [#{values.inspect}]"
    MailMan.smtp_settings = self.get_activemailer_settings
    MailMan.template_root = TEMPLATE_ROOT
    case self.id
    when SIGNUP_TRIM
      RAILS_DEFAULT_LOGGER.info ".. Sending TRIM SIGNUP ..."
      MailMan.deliver_signup_trim(values)
    when SIGNUP_PICIM
      RAILS_DEFAULT_LOGGER.info ".. Sending PICIM SIGNUP ..."
      MailMan.deliver_signup_picim(values)

    when RESET_PASSWORD_TRIM
      RAILS_DEFAULT_LOGGER.info ".. Sending TRIM Password Reset ..."
      MailMan.deliver_reset_password_trim(values)
    when RESET_PASSWORD_PICIM
      RAILS_DEFAULT_LOGGER.info ".. Sending PICIM Password Reset ..."
      MailMan.deliver_reset_password_picim(values)
      
    when REPORT_SPAM
      RAILS_DEFAULT_LOGGER.info ".. Sending SPAM REPORT ..."
      MailMan.deliver_report_spam(values)
    when REPORT_PORN
      RAILS_DEFAULT_LOGGER.info ".. Sending PORN REPORT ..."
      MailMan.deliver_report_porn(values)

    else
      RAILS_DEFAULT_LOGGER.info ".. REQUEST to Email UNDEFINED EMAIL [#{self.code}]" end
  end
  def get_activemailer_settings
    case self.id
    when SIGNUP_TRIM
      return self.smtp_trim
    when SIGNUP_PICIM
      return self.smtp_picim

    when RESET_PASSWORD_TRIM
      return self.smtp_trim 
    when RESET_PASSWORD_PICIM
      return self.smtp_picim

    when REPORT_SPAM
      return self.smtp_trim
    when REPORT_PORN
      return self.smtp_picim

    else
      return self.smtp_trim end
  end
  
  protected
  def smtp_trim
    { :address => "smtp.sendgrid.net", :domain => "tr.im", :port => 25, 
      :user_name => "ejw@nambu.com", :password => "Bsh5gsyeDD", :authentication => :login }
    # { :address => "smtp.mxes.net", :domain => "tr.im", :port => 25, 
    #   :user_name => "support_tr.im", :password => "trims33DF", :authentication => :login }
  end
  def smtp_picim
    smtp_trim.merge!({ :domain => "pic.im" })
  end
end
