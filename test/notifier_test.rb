require "test_helper"

class NotifierTest < Test::Unit::TestCase
  def setup
    SitemapNotifier::Notifier.reset
    SitemapNotifier::Notifier.configure do |config|
      config.environments = :all
    end
  end

  def test_configuration_block
    SitemapNotifier::Notifier.configure do |config|
      config.sitemap_url = "http://myconfigureddomain.com/sitemap.xml"
    end
    assert_equal "http://myconfigureddomain.com/sitemap.xml", SitemapNotifier::Notifier.sitemap_url
  end

  def test_configured_models_is_empty_as_default
    SitemapNotifier::Notifier.configure do |config|
    end
    assert_empty SitemapNotifier::Notifier.models
  end

  def test_waits_delay
    notifier = SitemapNotifier::Notifier
    notifier.configure do |config|
      config.sitemap_url = "http://test.dk/sitemap.xml"
      config.models = [Article]
      config.delay = 10
    end

    SitemapNotifier::Notifier.expects(:ping_all).twice

    Article.create!
    Article.create!
    Timecop.travel(Time.now + 20) do
      Article.create!
    end
  end

  def test_notifies_search_engines
    sitemap_url = "http://mydomain.dk/sitemap.xml"

    SitemapNotifier::Notifier.configure do |config|
      config.models = [Article]
      config.sitemap_url = sitemap_url
    end

    ["http://www.google.com/webmasters/sitemaps/ping?sitemap=#{CGI::escape(sitemap_url)}",
     "http://www.bing.com/webmaster/ping.aspx?siteMap=#{CGI::escape(sitemap_url)}"].each do |ping_url|
      Net::HTTP.expects(:get).with(URI.parse(ping_url))
    end
    Article.create! :title => "Test"
  end

  def test_notifies_for_configured_models
    SitemapNotifier::Notifier.configure do |config|
      config.models = [Article, Product]
      config.sitemap_url = "http://test.dk/sitemap.xml"
    end

    SitemapNotifier::Notifier.expects(:ping_all).twice

    [Article, Product, User].each do |model|
      model.create!
    end
  end

  def test_notifies_custom_ping_url
    sitemap_url = "http://test.dk/sitemap.xml"
    ping_url = "http://bla.dk/ping.php"

    SitemapNotifier::Notifier.configure do |config|
      config.models = [Article]
      config.sitemap_url = sitemap_url
      config.ping_urls << ping_url # TODO: Get this to work so we can test using "config.ping_urls << ping_url" instead
    end

    ["http://www.google.com/webmasters/sitemaps/ping?sitemap=#{CGI::escape(sitemap_url)}",
     "http://www.bing.com/webmaster/ping.aspx?siteMap=#{CGI::escape(sitemap_url)}",
     ping_url].each do |ping_url|
      Net::HTTP.expects(:get).with(URI.parse(ping_url))
    end

    Article.create!
  end
end