require "active_record"

module SitemapNotifier
  module ActiveRecord
    def self.included(base)
      [:create, :update, :destroy].each do |action|
        base.send("after_#{action}") do
          notify_sitemap(action)
        end
      end
    end

    def notify_sitemap(action)
      notifier = SitemapNotifier::Notifier
      
      if (notifier.notify_of_changes_to?(self.class, action)) && notify_sitemap?
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