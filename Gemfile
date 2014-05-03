source 'https://rubygems.org'

gem 'rails', '3.2.17'
gem 'sqlite3'

group :assets do
  gem 'sass-rails' # for datatables
  gem 'less-rails' # for bootstrap
  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.0.3'

  gem 'jquery-rails'
  gem 'jquery-datatables-rails', git: 'git://github.com/rweng/jquery-datatables-rails.git'
  gem 'twitter-typeahead-rails', '0.9.3', git: 'git://github.com/yourabi/twitter-typeahead-rails.git', tag: 'v0.9.3'
end

gem 'twitter-bootstrap-rails', git: 'git://github.com/seyhunak/twitter-bootstrap-rails.git'

group :development, :test do
  gem 'rspec-rails', '~> 3.0.0.beta'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'railroady'
end

group :production do
  gem 'unicorn'
  gem 'memcache-client'
end

gem 'simple_form'
gem 'audited-activerecord'
gem 'idn-ruby'
gem 'devise'
gem 'bert'
gem 'cancancan'
