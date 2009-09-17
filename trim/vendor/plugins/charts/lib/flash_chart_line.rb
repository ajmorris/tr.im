##
# Written by Eric Woodward, ejw@nambu.com.
# Copyright 2008-2009. The Nambu Network Inc. All Rights Reserved.
##

class FlashChartLine < FlashChart
  def initialize(hash = Hash.new)
    super(hash)
  end

  def html
    tmps = <<END_OF_STRING
<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" width="#{self.width}" height="#{self.height}" id="Column3D" codebase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0">
  <param name="movie" value="/flash/charts/Line.swf" />
  <param name="FlashVars" value="&dataXML=#{self.xmldata}&chartWidth=#{self.width}&chartHeight=#{self.height}" />
  <param name="quality" value="high" />
  <embed src="/flash/charts/Line.swf" flashVars="&dataXML=#{self.xmldata}&chartWidth=#{self.width}&chartHeight=#{self.height}" quality="high" width="#{self.width}" height="#{self.height}" name="Column3D" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" />
</object>
END_OF_STRING
    return tmps
  end
end
