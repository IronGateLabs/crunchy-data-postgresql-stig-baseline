require 'simplecov'
require 'simplecov-lcov'
require 'simplecov_json_formatter'

SimpleCov::Formatter::LcovFormatter.config do |c|
  c.report_with_single_file = true
  c.single_report_path = 'coverage/lcov.info'
end

# HTML for humans, Lcov for Codecov, JSON for SonarCloud's Ruby coverage sensor.
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::LcovFormatter,
    SimpleCov::Formatter::JSONFormatter
  ]
)

SimpleCov.start do
  add_filter %r{^/test/}
  add_filter %r{/gems/}
  track_files 'libraries/**/*.rb'
end

require 'minitest/autorun'
