require 'net/http'
require 'uri'
require 'cgi'

module SitemapNotifier
  class Notifier
    class << self
      # sitemap url
      attr_accessor :sitemap_url

      # source
      attr_writer :models
      def models
        @models ||= []
      end
      
      # delay
      attr_writer :delay
      def delay
        @delay ||= 600
      end
      
      # environments
      attr_writer :environments
      def environments
        @environments ||= [:production]
      end

      # current environment to enable testing
      attr_writer :env
      def env
        defined?(Rails) ? Rails.env.to_sym : @env
      end

      # urls
      attr_writer :urls
      def urls
        @urls ||= ["http://www.google.com/webmasters/sitemaps/ping?sitemap=%{sitemap_url}",
                   "http://www.bing.com/webmaster/ping.aspx?siteMap=%{sitemap_url}"]
                   # no Yahoo here, as they will be using Bing from september 15th, 2011
      end
      
      # running pid
      attr_accessor :running_pid

      def notify(url = nil)
        url ||= sitemap_url

        raise "sitemap_url not set - use SitemapNotifier::Notifier.sitemap_url = 'http://domain.com/sitemap.xml'" unless url
        
        if run? && ping?(url)
          Rails.logger.info "Notifying search engines of changes to sitemap..." if defined?(Rails)
          
          urls.each do |ping_url|
            ping_url.gsub! "%{sitemap_url}", escape_sitemap_url(url)
            if ping_url(ping_url)
              Rails.logger.info "#{ping_url} - ok" if defined?(Rails)
            else
              Rails.logger.info "#{ping_url} - failed" if defined?(Rails)
            end
          end
        end
      end

      def configure
        yield self
        if models.empty? && defined?(Rails)
          Rails.logger.warn "SitemapNotifier was configured without any models to trigger notifications. Search engines will therefore not be notified."
        end
      end

      # For testing purposes
      def reset_configuration
        [:@sitemap_url, :@models, :@delay, :@environments, :@urls].each do |var|
          remove_instance_variable var if instance_variable_defined?(var)
        end
      end

      def escape_sitemap_url(url)
        CGI::escape(url)
      end
      
      def ping_url(url)
        sitemap_notified(url)
        begin
          Net::HTTP.get(URI.parse(url))
          return true
        rescue
          return false
        end
      end

      def run?
        environments == :all || environments.include?(env)
      end

      def ping?(sitemap_url)
        last_notified = notified_at(sitemap_url)
        last_notified.nil? || Time.now > last_notified + delay
      end

      # Holds notified URLs like notification_times["http://mydomain.com/sitemap.xml"] # => 2013-02-05 19:10:29 +0100
      def notified_urls
        @notified_urls ||= {}
      end

      def notified_at(sitemap_url)
        notified_urls[sitemap_url]
      end

      def sitemap_notified(sitemap_url)
        notified_urls[sitemap_url] = Time.now
      end
    end
  end
end