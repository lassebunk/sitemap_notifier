Sitemap Notifier
================

Sitemap Notifier is a Ruby on Rails plugin that, when installed, automatically notifies Google, Bing, and Yahoo of changes to your models, i.e. changes to your sitemap. It also works in conjunction with the [dynamic_sitemaps](https://github.com/lassebunk/dynamic_sitemaps) plugin.

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
$ rails generate sitemap_notifier:install
```

Then, in *config/initializers/sitemap_notifier.rb*:

```ruby
SitemapNotifier::Notifier.configure do |config|
  # Replace this with your own url
  config.sitemap_url = "http://example.com/sitemap.xml"

  # Sources – default is :all for all models
  config.models = [Article, Category]

  # Enabled in which environments – default is [:production]
  config.environments = [:development, :production]

  # Delay to wait between notifications – default is 600 seconds
  config.delay = 30

  # Additional urls – be sure to call this after setting sitemap_url
  config.ping_urls << "http://localhost:3000/ping"
end
```

Then create or update a model:

```ruby
Article.create :title => "My New Article"
```

The search engines are then automatically notified.

After installation
------------------

After you install and configure the plugin, it'll automatically notify Google, Bing, and Yahoo every time you update a model. After each notification, it'll wait 10 minutes (by default) before notifying again. This is to ensure that for example a batch update won't trigger an equal amount of notifications.

Customization
-------------

### Per model sitemap URL

The sitemaps defaults to what you set in `SitemapNotifier::Notifier.sitemap_url`. If you want to use a different sitemap URL based on data in your models, you can override the `sitemap_url` method of each of your models like this:

```ruby
class Product < ActiveRecord::Base
  belongs_to :site

  def sitemap_url
    "http://#{site.domain}/sitemap.xml"
  end
end
```

### Conditional notifications

You can decide on model level whether the search engines should be pinged by overriding the `notify_sitemap?` method of your models:

```ruby
class Product < ActiveRecord::Base
  belongs_to :site

  def notify_sitemap?
    site.id == 1
  end
end
```

Copyright &copy; 2010-2013 Lasse Bunk, released under the MIT license
