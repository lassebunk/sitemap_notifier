module SitemapNotifier
  module ActiveRecord
    def notify_sitemap
      notifier = ::SitemapNotifier::Notifier
      
      if notifier.sources == :all || notifier.sources.include?(self.class.name.tableize.to_sym)
        notifier.notify!
      end
    end
    
    def self.included(base)
      base.after_save :notify_sitemap
    end
  end
end