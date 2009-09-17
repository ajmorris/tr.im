##
# Written by Eric Woodward, ejw@nambu.com.
# Copyright 2008-2009. The Nambu Network Inc. All Rights Reserved.
##

require 'cgi'

class FlashChart
  attr_accessor :height, :width, :values, :options, :links, :tool_texts
  
  def initialize(hash)
    hash.each do |key,value|
      self.instance_variable_set("@#{key}", value)
      self.class.send(:define_method, key, proc{self.instance_variable_get("@#{key}")})
      self.class.send(:define_method, "#{key}=", proc{|value| self.instance_variable_set("@#{key}", value)})
    end
    @width ||= 400
    @height ||= 250
    @values ||= Array.new                     ## values = [{ "label" => "0" }, {"label" => "2"}, {"label" => "3"}]
    @options ||= Hash.new                    ## options = diddo
    @links ||= nil
    @tool_texts ||= nil
  end

  protected
  def xmldata
    ss, i = String.new, 0
    @values.each {|hash|
      hash.each {|key, value|
        ss << "<set label='#{key}' value='#{value}' "
        ss << "link='#{CGI::escape(links[i])}' " if @links
        ss << "toolText='#{CGI::escape(tool_texts[i])}' " if @tool_texts
        ss << "/>"
      }
      i += 1
    }
    wrap_caption(ss, self.options)
  end
  def wrap_caption(internals, chart_options = {})  
    ss = "<chart "
    @options.each_pair {|key, value| ss << "#{key}='#{value}' " }
    "#{ss}>#{internals}</chart>"
  end
end
