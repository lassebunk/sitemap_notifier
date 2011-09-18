module SitemapNotifier
  module ActiveRecord
    def notify_sitemap
      ::SitemapNotifier::Notifier.notify!
    end
    
    def self.included(base)
      base.after_save :notify_sitemap
    end
  end
end