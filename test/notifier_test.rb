require "test_helper"

class NotifierTest < Test::Unit::TestCase
  def setup
    SitemapNotifier::Notifier.reset_configuration
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
end