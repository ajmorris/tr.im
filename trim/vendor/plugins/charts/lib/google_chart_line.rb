##
# Written by Eric Woodward, ejw@nambu.com.
# Copyright 2008-2009. The Nambu Network Inc. All Rights Reserved.
##

class GoogleChartLine < GoogleChart
  def initialize(hash = Hash.new)
    super(hash)
    self.type = CHART_TYPE_LINE
  end
  
  protected
  def chart_extras
    tmps  = "&chxt=y&chxl=0:|0|#{self.max_series_value}"
    tmps << "&chma=20,20,10,30"
    return tmps
  end
end
