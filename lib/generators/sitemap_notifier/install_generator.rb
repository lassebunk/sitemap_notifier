module SitemapNotifier
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    
    desc "Creates an initializer for breadcrumbs in config/initializers/sitemap_notifier.rb"
    def create_initializer
      copy_file "initializer.rb", "config/initializers/sitemap_notifier.rb"
    end
  end
end