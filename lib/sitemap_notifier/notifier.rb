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
        @models ||= :all
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
      
      # urls
      attr_writer :urls
      def urls
        @urls ||= ["http://www.google.com/webmasters/sitemaps/ping?sitemap=#{CGI::escape(sitemap_url)}",
                   "http://www.bing.com/webmaster/ping.aspx?siteMap=#{CGI::escape(sitemap_url)}"]
                   # no Yahoo here, as they will be using Bing from september 15th, 2011
      end
      
      # running pid
      attr_accessor :running_pid

      def notify
        raise "sitemap_url not set - use SitemapNotifier::Notifier.sitemap_url = 'xx'" unless sitemap_url
        
        if (environments == :all || environments.include?(Rails.env.to_sym)) && !running?
          self.running_pid = fork do
            Rails.logger.info "Notifying search engines of changes to sitemap..."
            
            urls.each do |url|
              if get_url(url)
                Rails.logger.info "#{url} - ok"
              else
                Rails.logger.info "#{url} - failed"
              end
            end
            
            sleep delay
            exit
          end
        end
      end

      def configure
        yield self
      end
      
    protected
    
      def get_url(url)
        uri = URI.parse(url)
        begin
          return Net::HTTPSuccess === Net::HTTP.get_response(uri)
        rescue Exception
          return false
        end
      end
      
      def running?
        return false unless running_pid
        
        begin
          Process.getpgid(running_pid)
          true
        rescue Errno::ESRCH
          false
        end
      end
    end
  end
end