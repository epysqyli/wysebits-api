source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.1'

gem 'rails', '~> 6.1.4', '>= 6.1.4.1'

gem 'pg', '~> 1.1'

gem 'puma', '~> 5.0'

gem 'activerecord-import'
gem 'bcrypt', '~> 3.1.7'
gem 'json'
gem 'jwt', '~> 2.2', '>= 2.2.3'
gem 'simple_command', '~> 0.1.0'

gem 'bootsnap', '>= 1.4.4', require: false

gem 'rack-cors'

group :development, :test do
  gem 'better_errors', '~> 2.9', '>= 2.9.1'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'faker', '~> 2.19'
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'spring'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
