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

namespace :trim do
  desc "Creates and inserts initial tr.im databases for current and test environments FOR THE FIRST TIME"
  task :setup => :environment do
    puts "CREATING DATABASE ..."
    system("rake db:create --trace")
    puts "DONE.\n\n"

    puts "CREATING TABLES ..."
    system("rake db:migrate --trace")
    puts "DONE.\n\n"

    puts "POPULATING TABLES (this could take a bit) ..."
    system("rake db:populate --trace")
    puts "DONE.\n\n"

    puts "RESETING TEST DATABASE"
    system("rake environment RAILS_ENV=test db:create --trace ")
    system("rake db:test:clone_structure --trace")
    system("rake environment RAILS_ENV=test db:populate --trace")
    puts "DONE."
  end
end
