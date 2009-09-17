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

class TrimObject
  def TrimObject.get_random_code(length)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    rval = String.new
    1.upto(length) {|i| rval << chars[rand(chars.size - 1)]}
    return rval
  end
  def TrimObject.get_basemade_value(i)
    sixtytwo = ('0'..'9').to_a + ('a'..'z').to_a + ('A'..'Z').to_a
    tmps = String.new
    while i > 0
      i,r = i.divmod(62)
      tmps = (sixtytwo[r]) + tmps
    end
    return tmps
  end
end
