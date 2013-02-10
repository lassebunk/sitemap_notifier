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

      # Set models that should trigger notification.
      #
      # If you supply a hash, you can specify which actions should trigger notifications using +:create+, +:update+, +:destroy+, or +:all+.
      #
      # If you supply an array, all creates, updates, and deletes will trigger notification.
      #
      # Example:
      #
      #   # Will trigger notifications on creates, updates, and destroys on articles and products:
      #   SitemapNotifier::Notifier.models = [Article, Product]
      #
      #   # Will trigger notifications on the specified actions:
      #   config.models = { Article => [:create, :destroy],
      #                     Product => :update,
      #                     Page => :all }
      def models
        @models ||= {}
      end
      
      def models=(hash_or_array)
        if hash_or_array == :all
          @models = { :all => :all }
        elsif hash_or_array.is_a?(Array)
          @models = Hash[hash_or_array.map { |model| [model, :all] }]
        else
          @models = hash_or_array
        end
      end
      
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

      # Whether to run the notification pings in the background.
      # Default: +true+
      #
      # Example:
      #
      #   SitemapNotifier::Notifier.background = false
      def background
        return @background if defined?(@background)
        @background = true
      end
      attr_writer :background
      
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
        p = Proc.new do
          Rails.logger.info "Notifying search engines of changes to sitemap #{url}..." if defined?(Rails)
          
          escaped_url = escape_sitemap_url(url)

          ping_urls.each do |url|
            url.gsub! "%{sitemap_url}", escaped_url
            if ping_url(url)
              Rails.logger.info "Successfully notified #{url}" if defined?(Rails)
            else
              Rails.logger.info "Failed to notify #{url}" if defined?(Rails)
            end
          end
        end

        background ? Thread.new(&p) : p.call
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
        [:@sitemap_url, :@models, :@delay, :@environments, :@ping_urls, :@background, :@notified_urls].each do |var|
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
      def notify_of_changes_to?(model, action)
        valid_actions = models[model] || models[:all]

        return valid_actions == :all ||
               valid_actions == action ||
               (valid_actions.is_a?(Array) && valid_actions.include?(action))
      end
    end
  end
end