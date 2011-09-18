require 'net/http'
require 'uri'
require 'cgi'

module SitemapNotifier
  class Notifier
    class << self
      attr_accessor :delay
      attr_accessor :sitemap_url
      attr_accessor :environments
      
      def notify!
        raise "environments not set – use SitemapNotifier::Notifier.environments = [:xx, :xx]" unless environments
        raise "delay not set – use SitemapNotifier::Notifier.delay = xx" unless delay
        raise "sitemap_url not set – use SitemapNotifier::Notifier.sitemap_url = 'xx'" unless sitemap_url
        
        if environments.include?(Rails.env.to_sym)
          if @thread.nil? || @thread.status == false
            @thread = Thread.new do
              Rails.logger.info "Notifying search engines of changes to sitemap..."

              get_url "http://www.google.com/webmasters/sitemaps/ping?sitemap=#{CGI::escape(sitemap_url)}"
              get_url "http://www.bing.com/webmaster/ping.aspx?siteMap=#{CGI::escape(sitemap_url)}"
              # no Yahoo here, as they will be using Bing from september 15th, 2011

              sleep delay
            end
          end
        end
      end
      
    protected
    
      def get_url(url)
        uri = URI.parse(url)
        Net::HTTP.get_response(uri)
      end
    end
  end
end