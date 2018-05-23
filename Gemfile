# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gem "decidim", path: "."

gem "puma", "~> 3.0"
gem "uglifier", ">= 1.3.0"

gem "faker"

group :development, :test do
  gem "byebug", platform: :mri

  gem "decidim-dev", path: "."

gem 'faker'
end

group :development do
  gem "letter_opener_web", "~> 1.3.0"
  gem "listen", "~> 3.1.0"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console"
gem 'faker'
end
