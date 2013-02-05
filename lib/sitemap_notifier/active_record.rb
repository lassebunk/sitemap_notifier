module SitemapNotifier
  module ActiveRecord
    def notify_sitemap
      notifier = ::SitemapNotifier::Notifier
      
      if notifier.models == :all || notifier.models.include?(self.class)
        notifier.notify!
      end
    end
    
    def self.included(base)
      base.after_save :notify_sitemap
    end
  end
end

ActiveRecord::Base.send :include, SitemapNotifier::ActiveRecord