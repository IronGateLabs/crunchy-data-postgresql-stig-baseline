source 'https://rubygems.org'

# Pinned to InSpec 5: InSpec 6+ requires a commercial Chef license key, which
# would force every contributor/CI run to hold one. v5 is the last license-free
# line and is sufficient for this profile (inspec.yml requires only >= 4.0).
gem 'inspec', '~> 5.22'
gem 'inspec-bin', '~> 5.22'
gem 'rake'

group :development, :test do
  gem 'minitest'
  gem 'pry-byebug'
  gem 'rubocop'
  gem 'rubocop-rake'
  gem 'simplecov', require: false
  gem 'simplecov-lcov', require: false
end
