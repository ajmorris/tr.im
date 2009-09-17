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

class MailMan < ActionMailer::Base
  def signup_trim(values)
    recipients values["to"]
    from "support@tr.im"
    subject "Your New Account at tr.im"
    body :username => values["login"]
  end
  def report_spam(values)
    recipients values["to"]
    from "support@tr.im"
    subject "tr.im Spam Report"
    body :text => values["text"]
  end
  def reset_password_trim(values)
    recipients values["to"]
    from "support@tr.im"
    subject "Your tr.im Password Reset"
    body :username => values["login"], :code => values["code"]
  end
  
  def signup_picim(values)
    recipients values["to"]
    from "support@pic.im"
    subject "Your New Account at pic.im"
    body :username => values["login"]
  end
  def report_porn(values)
    recipients values["to"]
    from "support@pic.im"
    subject "pic.im Abuse Report"
    body :url => values["url"]
  end
  def reset_password_picim(values)
    recipients values["to"]
    from "support@pic.im"
    subject "Your pic.im Password Reset"
    body :username => values["login"], :code => values["code"]
  end
end
