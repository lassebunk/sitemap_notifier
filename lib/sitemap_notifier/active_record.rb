require "active_record"

module SitemapNotifier
  module ActiveRecord
    def self.included(base)
      base.after_save :notify_sitemap
    end

    def notify_sitemap
      notifier = SitemapNotifier::Notifier
      
      if (notifier.notify_of_changes_to?(self.class)) && notify_sitemap?
        notifier.run(sitemap_url)
      end
    end

    def notify_sitemap?
      true
    end

    def sitemap_url
      SitemapNotifier::Notifier.sitemap_url
    end
  end
end

ActiveRecord::Base.send :include, SitemapNotifier::ActiveRecord