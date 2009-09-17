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

##
# The test environment is used exclusively to run your application's test suite. You never need to work with it otherwise.
# Remember that your test database is "scratch space" for the test suite and is wiped and recreated between test runs.
# Don't rely on the data there!
##

## The production environment is meant for finished, "live" apps. Code is not reloaded
## between requests
config.cache_classes = true

## Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

## Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.cache_template_loading            = true

## Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

## Tell Action Mailer not to deliver emails to the real world. The :test delivery method accumulates sent emails
## in the ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

## Use SQL instead of Active Record's schema dumper when creating the test database. This is necessary if your schema
## can't be completely dumped by the schema dumper, like if you have constraints or database-specific column types
# config.active_record.schema_format = :sql

## Ensure we are on debug for development
config.log_level = :debug

## Memcached
config.cache_store = :mem_cache_store, ['10.176.102.92:11211', '10.176.101.34:11211'], { :namespace => 'trim_test' }

## Starling Qs
STARLING_QS = '10.176.102.92:22122'
