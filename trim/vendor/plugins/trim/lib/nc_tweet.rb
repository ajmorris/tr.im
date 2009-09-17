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

class NCTweet
  attr_accessor :text

  def initialize(hash)
    hash.each do |key, value|
      self.instance_variable_set("@#{key}", value)
      self.class.send(:define_method, key, proc { self.instance_variable_get("@#{key}") })
      self.class.send(:define_method, "#{key}=", proc {|value| self.instance_variable_set("@#{key}", value) })
    end
    @text ||= String.new
  end

  def has_url?
    (self.text.include?("http://") || self.text.include?("https://")) && self.get_urls.length > 0
  end
  def get_urls
    urls = Array.new
    for word in self.text.split(' ')
      if word.start_with?("(") && word.end_with?(")")
        word.delete!("(")
        word.delete!(")")
      end
      if word.start_with?("[") && word.end_with?("]")
        word.delete!("[")
        word.delete!("]")
      end
      word.chomp!(".") if word.end_with?(".")
      word.chomp!(",") if word.end_with?(",")
      urls << word if word.start_with?("http://") || word.start_with?("https://")
    end
    return urls
  end
end
