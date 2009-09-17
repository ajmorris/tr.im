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

## In the development environment your application's code is reloaded on
## every request.
config.cache_classes = false

## Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

## Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs             = true
config.action_controller.perform_caching = false

## Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

## Ensure we are on debug for development
config.log_level = :debug

## Memcached
config.cache_store = :mem_cache_store, '127.0.0.1:14414', { :namespace => 'trim_reds_development' }

## Starling Qs
STARLING_QS = ['127.0.0.1:22122']

