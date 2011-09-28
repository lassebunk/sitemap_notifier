# replace this with your own url
SitemapNotifier::Notifier.sitemap_url = "http://example.com/sitemap.xml"

# source models – default is :all for all models
#   SitemapNotifier::Notifier.models = [Article, Category]

# enabled in which environments – default is [:production]
#   SitemapNotifier::Notifier.environments = [:development, :production]
#   SitemapNotifier::Notifier.environments = :all

# delay to wait between notifications – default is 600 seconds
#   SitemapNotifier::Notifier.delay = 30

# additional urls – be sure to call this after setting sitemap_url
#   SitemapNotifier::Notifier.urls << "http://localhost:3000/ping"