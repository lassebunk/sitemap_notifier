SitemapNotifier::Notifier.configure do |config|
  # Set URL to your sitemap. This is required.
  #   config.sitemap_url = "http://example.com/sitemap.xml"
  #
  # This can also be configured per model basis,
  # see https://github.com/lassebunk/sitemap_notifier#per-model-sitemap-url

  # Models that should trigger notification of search engines
  #   config.models = [Article, Category]

  # Enabled in which environments – default is [:production]
  #   config.environments = [:development, :production]
  # or
  #   config.environments = :all

  # Delay to wait between notifications – default is 600 seconds
  #   config.delay = 2.minutes

  # Additional urls to ping
  #   config.ping_urls << "http://localhost:3000/ping?sitemap=%{sitemap_url}"
end