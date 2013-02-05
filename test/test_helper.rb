$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'test/unit'
require 'sitemap_notifier'
require 'db'
require 'timecop'
require 'fakeweb'
require 'mocha/setup'

# Catch requests to Google and Bing
[%r{http://www\.google\.com/webmasters/sitemaps/ping\?sitemap=},
 %r{http://www\.bing\.com/webmaster/ping\.aspx\?siteMap=}].each do |url|
   FakeWeb.register_uri(:get, url, :body => "OK!")  
end

# Catch all other HTTP requests and make them fail so we don't accidentally make real HTTP requests in the test suite
FakeWeb.register_uri(:any, //, :body => "Fail! (change this in test_helper.rb)", :status => ["400", "Bad Request"])