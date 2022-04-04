source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.1'

gem 'bcrypt', '~> 3.1.7'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'figaro'
gem 'json'
gem 'jwt', '~> 2.2', '>= 2.2.3'
gem 'mini_magick', '~> 4.11'
gem 'pagy', '~> 5.4'
gem 'pg', '~> 1.1'
gem 'pg_search', '~> 2.3', '>= 2.3.6'
gem 'puma', '~> 5.0'
gem 'rack-cors'
gem 'rails', '~> 6.1.4', '>= 6.1.4.1'
gem 'sidekiq', '~> 6.4', '>= 6.4.1'
gem 'simple_command', '~> 0.1.0'
gem 'whenever', '~> 1.0', require: false

group :development, :test do
  gem 'better_errors', '~> 2.9', '>= 2.9.1'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'faker', '~> 2.19'
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'spring'
end

group :development, :production do
  gem 'activerecord-import'
  gem 'parallel'
  gem 'pry'
  gem 'redis'
  gem 'smarter_csv'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
