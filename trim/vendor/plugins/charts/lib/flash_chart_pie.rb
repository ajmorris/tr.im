##
# Written by Eric Woodward, ejw@nambu.com.
# Copyright 2008-2009. The Nambu Network Inc. All Rights Reserved.
##

class FlashChartPie < FlashChart
  def initialize(hash = Hash.new)
    super(hash)
  end
  
  def html
    tmps = <<END_OF_STRING
<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" width="#{self.width}" height="#{self.height}" id="Pie3D" codebase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0">
  <param name="movie" value="/flash/charts/Pie3D.swf" />
  <param name="FlashVars" value="&dataXML=#{self.xmldata}&chartWidth=#{self.width}&chartHeight=#{self.height}" />
  <param name="quality" value="high" />
  <embed src="/flash/charts/Pie3D.swf" flashVars="&dataXML=#{self.xmldata}&chartWidth=#{self.width}&chartHeight=#{self.height}" quality="high" width="#{self.width}" height="#{self.height}" name="Column3D" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" />
</object>
END_OF_STRING
    return tmps
  end
end

## PIE CHART EXAMPLE XML
# <chart palette='4' decimals='0' enableSmartLabels='1' enableRotation='0'
#    bgColor='99CCFF,FFFFFF' bgAlpha='40,100' bgRatio='0,100' bgAngle='360' showBorder='1' startingAngle='70'>
#   <set label='France' value='17'  />
#   <set label='India' value='12' />
#   <set label='Brazil' value='18' />
#   <set label='USA' value='8' isSliced='1'/>
#   <set label='Australia' value='10' isSliced='1'/>
#   <set label='Japan' value='16' isSliced='1'/>
#   <set label='England' value='11' />
#   <set label='Nigeria' value='12' />
#	  <set label='Italy' value='8' />
#   <set label='China' value='10' />
#   <set label='Canada' value='19'/>
#   <set label='Germany' value='15'/>
# </chart>
##
