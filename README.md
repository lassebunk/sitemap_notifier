Sitemap Notifier
================

Sitemap Notifier is a Ruby on Rails plugin that, when installed, automatically notifies Google, Bing, Yahoo, and Ask.com of changes to your models, i.e. changes to your sitemap. It also works in conjunction with the [dynamic_sitemaps](https://github.com/lassebunk/dynamic_sitemaps) plugin.

Installation
------------

In your *Gemfile*:

```ruby
gem 'sitemap_notifier'
```
  
And run:

```bash
$ bundle install
```

Example
-------

Start by generating an initializer:

```bash
$ rails generate sitemap_notifier sitemap_notifier
```

And, in *config/initializers/sitemap_notifier.rb*:

```ruby
# replace this with your own url
SitemapNotifier::Notifier.sitemap_url = "http://example.com/sitemap.xml"

# sources – default is :all for all models
SitemapNotifier::Notifier.models = [Article, Category]

# enabled in which environments – default is [:production]
SitemapNotifier::Notifier.environments = [:development, :production]

# delay to wait between notifications – default is 600 seconds
SitemapNotifier::Notifier.delay = 30

# additional urls – be sure to call this after setting sitemap_url
SitemapNotifier::Notifier.urls << "http://localhost:3000/ping"
```

Then create or update a model:

```ruby
Article.create :title => "My New Article"
```

The search engines are then automatically notified.

After installation
------------------

After you install and configure the plugin, it'll automatically notify Google, Bing, Yahoo, and Ask.com every time you update a model. After each notification, it'll wait 10 minutes (by default) before notifying again. This is to ensure that for example a batch update won't trigger an equal amount of notifications.

Copyright &copy; 2010-2013 Lasse Bunk, released under the MIT license
