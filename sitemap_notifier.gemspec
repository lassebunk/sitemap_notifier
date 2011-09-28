Gem::Specification.new do |s|
  s.name = "sitemap_notifier"
  s.version = "0.0.4"

  s.author = "Lasse Bunk"
  s.email = "lassebunk@gmail.com"
  s.description = "Ruby on Rails plugin that automatically notifies Google, Bing, Yahoo, and Ask.com of changes to your models, i.e. changes to your sitemap."
  s.summary = "Automatically notify search engines when your models are updated."
  s.homepage = "http://github.com/lassebunk/sitemap_notifier"
  s.files = Dir['lib/**/*.rb']
  s.require_paths = ["lib"]
end