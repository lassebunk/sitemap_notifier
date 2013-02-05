# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sitemap_notifier/version'

Gem::Specification.new do |gem|
  gem.name          = "sitemap_notifier"
  gem.version       = SitemapNotifier::VERSION
  gem.authors       = ["Lasse Bunk"]
  gem.email         = ["lassebunk@gmail.com"]
  gem.description   = %q{Ruby on Rails plugin that automatically notifies Google, Bing, Yahoo, and Ask.com of changes to your models, i.e. changes to your sitemap.}
  gem.summary       = %q{Automatically notify search engines when your models are updated.}
  gem.homepage      = "http://github.com/lassebunk/sitemap_notifier"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^test/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake"
end
