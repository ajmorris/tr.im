##
# Written by Eric Woodward, ejw@nambu.com.
# Copyright 2008-2009. The Nambu Network Inc. All Rights Reserved.
##

class GoogleChartBar < GoogleChart
  def initialize(hash = Hash.new)
    super(hash)
    self.type = CHART_TYPE_BAR
  end
  
  protected
  def chart_extras
    tmps  = "&chxt=y&chxl=0:|0|#{self.max_series_value}"
    tmps << "&chbh=#{self.bar_width},12"
    tmps << "&chma=20,20,10,20"
    return tmps
  end
  def bar_width
    ((self.width - (@data.length * 12) - 25) / @data.length).to_i
  end
end
