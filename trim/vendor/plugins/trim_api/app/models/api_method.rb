##
# Written by Eric Woodward, ejw@nambu.com.
# Copyright 2008-2009. The Nambu Network Inc. All Rights Reserved.
##

class ApiMethod < ActiveRecord::Base
  RESTRICTED_YES = "YES"
  RESTRICTED_NO = "NO"
    
  belongs_to :website
  has_many :limits, :class_name => "ApiLimit", :foreign_key => "method_id"
  has_many :overrides, :class_name => "ApiOverride", :foreign_key => "api_key_id"
  
  def restricted?
    self.restricted == RESTRICTED_YES
  end
end
