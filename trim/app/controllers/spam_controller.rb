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

class SpamController < ApplicationController
  before_filter :ajax?, :only => [ :report ]

  def index
    @pt = "#{WEBSITE_CONFIG['website_domain']} | Report Spam Abuse of #{WEBSITE_CONFIG['website_domain']} URLs"
    @tab = "none"
  end

  def report
    if params[:report] && (not params[:report][:text].blank?)
      spawn do
        email = TrimEmail.find(TrimEmail::REPORT_SPAM)
        email.deliver({ "to" => "support@tr.im", "text" => params[:report][:text] })
      end
      render :update do |page|
        page.replace_html 'spam_report', :partial => "done" end
    end
  end

  def redirect
    @pt = "#{WEBSITE_CONFIG['website_domain']} | Spam Rediretion Request"
    @tab = "none"
  end
end
