##
# Written by Eric Woodward, ejw@nambu.com.
# Copyright 2008-2009. The Nambu Network Inc. All Rights Reserved.
##

class GoogleChart
  attr_accessor :height, :width, :title, :type

  CHART_TYPE_PIE = "p"
  CHART_TYPE_BAR = "bvs"
  CHART_TYPE_LINE = "lc"
  CHART_TYPE_PIE_3D = "p3"
  CHART_COLOURS = [ "", "" ]

  def initialize(hash)
    hash.each do |key,value|
      self.instance_variable_set("@#{key}", value)
      self.class.send(:define_method, key, proc{self.instance_variable_get("@#{key}")})
      self.class.send(:define_method, "#{key}=", proc{|value| self.instance_variable_set("@#{key}", value)})
    end
    @type ||= CHART_TYPE_PIE
    @width ||= 100
    @height ||= 100
    @title ||= "Standard Google Chart"
    @data, @labels = Array.new, Array.new
  end

  def append_data(value)
    @data << value
  end
  def append_label(label)
    @labels << label
  end
  
  def set_series(values)
    @data = values
  end
  def set_labels(labels)
    @labels = labels
  end
  
  def series_for_google
    rval = Array.new
    max = self.max_series_value
    @data.each {|value|
      if value.to_i > 0 
        rval << ((value.to_f / max.to_f) * 100).to_i
      else rval << 0 end
    }
    return rval
  end
  def max_series_value
    rval = 0
    @data.each {|value| rval = value.to_i if value.to_i > rval }
    return rval
  end

  def html
    return "<img src='#{self.url}' width='#{self.width}' height='#{self.height}'>"
  end

  protected
  def url
    tmps  = "http://chart.apis.google.com/chart?cht=#{self.type}&chs=#{self.width}x#{self.height}"
    tmps << "&chd=t:#{self.series_for_google.join(',')}"
    tmps << "&chl=#{@labels.join('|')}" if self.type != CHART_TYPE_BAR
    tmps << "&chtt=#{self.title.gsub(/\s/, '+')}&chts=000000,12"
    tmps << self.chart_extras
    return tmps
  end
end
