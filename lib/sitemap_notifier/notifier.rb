require 'net/http'
require 'uri'
require 'cgi'

module SitemapNotifier
  class Notifier
    class << self
      # The default sitemap URL to send to search engines.
      #
      # Example:
      #
      #   SitemapNotifier::Notifier.sitemap_url = "http://test.dk/sitemap.xml"
      #
      # The default sitemap URL can be overridden on model level:
      #
      #   class Product < ActiveRecord::Base
      #     belongs_to :site
      #
      #     def sitemap_url
      #       "http://#{site.domain}/sitemap.xml"
      #     end
      #   end
      attr_accessor :sitemap_url

      # Models that should trigger notification of search engines.
      #
      # Example:
      #
      #   SitemapNotifier::Notifier.models = [Article, Product]
      def models
        @models ||= []
      end
      attr_writer :models
      
      # Seconds to wait between notifications of the search engines.
      # Default: 10 minutes
      #
      # Example:
      #
      #   SitemapNotifier::Notifier.delay = 2.minutes
      def delay
        @delay ||= 600
      end
      attr_writer :delay
      
      # Environments where sitemap notifications should be triggered.
      #
      # Example:
      #
      #   SitemapNotifier::Notifier.environments = [:development, :production]
      def environments
        @environments ||= [:production]
      end
      attr_writer :environments

      # Current environment. If not set manually, it returns the current Rails environment, like +:development:+ or +:production+.
      def env
        defined?(Rails) ? Rails.env.to_sym : @env
      end
      attr_writer :env

      # URLs to be pinged / notified of changes to sitemap.
      # Default is Google and Bing (and therefore Yahoo).
      #
      # Example:
      #
      #   SitemapNotifier::Notifier.ping_urls << "http://mydomain.com/ping?sitemap=%{sitemap_url}"
      #
      # The sitemap URL will then be interpolated into the ping URL at runtime.
      def ping_urls
        @ping_urls ||= ["http://www.google.com/webmasters/sitemaps/ping?sitemap=%{sitemap_url}",
                        "http://www.bing.com/webmaster/ping.aspx?siteMap=%{sitemap_url}"]
                   # no Yahoo here, as they will be using Bing from september 15th, 2011
      end
      attr_writer :ping_urls
      
      # Runs the search engine notifications after checking environment and delay.
      def run(url = nil)
        url ||= sitemap_url

        raise "sitemap_url not set - use SitemapNotifier::Notifier.sitemap_url = 'http://domain.com/sitemap.xml'" unless url

        if (environments == :all || environments.include?(env)) && ping?(url)
          ping_all url
          sitemap_notified url
        end
      end

      # Pings all the configured search engines with the supplied +url+.
      def ping_all(url)
        Rails.logger.info "Notifying search engines of changes to sitemap..." if defined?(Rails)
        
        escaped_url = escape_sitemap_url(url)

        ping_urls.each do |url|
          url.gsub! "%{sitemap_url}", escaped_url
          if ping_url(url)
            Rails.logger.info "#{ping_url} - ok" if defined?(Rails)
          else
            Rails.logger.info "#{ping_url} - failed" if defined?(Rails)
          end
        end
      end

      # Yields a configuration block to configure the notifier.
      #
      # Example:
      #
      #   SitemapNotifier::Notifier.configure do |config|
      #     config.sitemap_url = "http://test.dk/sitemap.xml"
      #   end
      def configure
        yield self
        if models.is_a?(Array) && models.empty? && defined?(Rails)
          Rails.logger.warn "SitemapNotifier was configured without any models to trigger notifications. Search engines will therefore not be notified."
        end
      end

      # For testing purposes. Resets all configuration and information about notified sitemaps.
      def reset
        [:@sitemap_url, :@models, :@delay, :@environments, :@ping_urls, :@notified_urls].each do |var|
          remove_instance_variable var if instance_variable_defined?(var)
        end
      end

      # URL encodes the given +url+.
      def escape_sitemap_url(url)
        CGI::escape(url)
      end
      
      # Makes a GET request to the supplied +url+. Returns +true+ when successful, +false+ otherwise.
      def ping_url(url)
        begin
          Net::HTTP.get(URI.parse(url))
          return true
        rescue
          return false
        end
      end

      # Returns +true+ if search engines should be modified. Returns +false+ if the configured +delay+ hasn't been met.
      def ping?(sitemap_url)
        last_notified = notified_at(sitemap_url)
        last_notified.nil? || Time.now >= last_notified + delay
      end

      # Holds notified URL times like notified_urls["http://mydomain.com/sitemap.xml"] # => 2013-02-05 19:10:29 +0100
      def notified_urls
        @notified_urls ||= {}
      end

      # Returns the latest notification time for the given URL.
      def notified_at(sitemap_url)
        notified_urls[sitemap_url]
      end

      # Stores notification time for the given URL.
      def sitemap_notified(sitemap_url)
        notified_urls[sitemap_url] = Time.now
      end

      # Returns +true+ if changes to the given model class should trigger notifications.
      def notify_of_changes_to?(model)
        models == :all || models.include?(model)
      end
    end
  end
end