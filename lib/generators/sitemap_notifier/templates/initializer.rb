SitemapNotifier::Notifier.configure do |config|
  # Set URL to your sitemap. This is required.
  #   config.sitemap_url = "http://example.com/sitemap.xml"
  #
  # This can also be configured per model basis,
  # see https://github.com/lassebunk/sitemap_notifier#per-model-sitemap-url

  # Models that should trigger notification of search engines.
  # It will trigger on creates, updates, and destroys af those models.
  #   config.models = [Article, Category]

  # To trigger notifications on the specified actions:
  #   config.models = { Article => [:create, :destroy],
  #                     Product => :update,
  #                     Page => :all }

  # Enabled in which environments – default is [:production]
  #   config.environments = [:development, :production]
  # or
  #   config.environments = :all

  # Delay to wait between notifications – default is 10 minutes
  #   config.delay = 2.minutes

  # Additional urls to ping
  #   config.ping_urls << "http://localhost:3000/ping?sitemap=%{sitemap_url}"

  # If you don't want the notifications to run in the background
  #   config.background = false
end