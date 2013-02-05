require "active_record"

module SitemapNotifier
  module ActiveRecord
    def self.included(base)
      base.after_save :notify_sitemap
    end

    def notify_sitemap
      notifier = SitemapNotifier::Notifier
      
      if notifier.models == :all || notifier.models.include?(self.class)
        notifier.notify
      end
    end

    def sitemap_url
      SitemapNotifier::Notifier.sitemap_url
    end
  end
end

ActiveRecord::Base.send :include, SitemapNotifier::ActiveRecord