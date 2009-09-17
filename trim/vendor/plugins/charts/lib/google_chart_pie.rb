##
# Written by Eric Woodward, ejw@nambu.com.
# Copyright 2008-2009. The Nambu Network Inc. All Rights Reserved.
##

class GoogleChartPie < GoogleChart
  def initialize(hash = Hash.new)
    super(hash)
    self.type = CHART_TYPE_PIE
  end
  
  protected
  def chart_extras
    tmps = "&chma=10,10,10,10"
    return tmps
  end
end
