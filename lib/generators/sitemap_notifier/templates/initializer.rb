SitemapNotifier::Notifier.configure do |config|
  config.sitemap_url = "http://example.com/sitemap.xml"

  # config.models = [Article, Category]

  # enabled in which environments – default is [:production]
  #   config.environments = [:development, :production]
  #   config.environments = :all

  # delay to wait between notifications – default is 600 seconds
  #   config.delay = 30

  # additional urls – be sure to call this after setting sitemap_url
  #   config.urls << "http://localhost:3000/ping"
end