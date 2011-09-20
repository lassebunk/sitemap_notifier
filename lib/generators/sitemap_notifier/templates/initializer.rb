# enabled in which environments
SitemapNotifier::Notifier.environments = [:development, :test, :production]

# wait 10 minutes between notifications
SitemapNotifier::Notifier.delay = 600

# replace this with your own url
SitemapNotifier::Notifier.sitemap_url = "http://example.com/sitemap.xml"

# additional urls
# SitemapNotifier::Notifier.urls << "http://localhost:3000/ping"