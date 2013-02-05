require "test_helper"

class NotifierTest < Test::Unit::TestCase
  def setup
    SitemapNotifier::Notifier.reset_configuration
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
      config.delay = 10
      config.environments = []
    end

    url = "http://test.dk"
    assert notifier.ping?(url), "Didn't ping URL."

    notifier.ping_url(url)
    assert !notifier.ping?(url), "Didn't wait before pinging again."

    Timecop.travel(Time.now + 20) do
      assert notifier.ping?(url), "Didn't ping after waiting."
    end
  end
end