require "active_record"

ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => ":memory:"

ActiveRecord::Migration.create_table :articles do |t|
  t.string :title
end

ActiveRecord::Migration.create_table :products do |t|
  t.string :name
end

ActiveRecord::Migration.create_table :users do |t|
  t.string :name
end

ActiveRecord::Migration.create_table :sites do |t|
  t.string :name
  t.boolean :has_sitemap
end

# Standard model to trigger notifications
class Article < ActiveRecord::Base
end

# Model with custom sitemap URL
class Product < ActiveRecord::Base
  def sitemap_url
    "http://mycustomurl.com/sitemapfile.xml"
  end
end

# Model that should not trigger notifications
class User < ActiveRecord::Base
end

# Model that has conditional notifications
class Site < ActiveRecord::Base
  def notify_sitemap?
    has_sitemap?
  end
end