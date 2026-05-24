# !/usr/bin/env rake

require 'rake/testtask'

namespace :inspec do
  desc 'Validate the InSpec profile'
  task :check do
    sh 'bundle exec inspec check .'
  end
end

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.warning = false
end

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:lint) do |task|
    task.options += %w[--display-cop-names --no-color --parallel]
  end
rescue LoadError
  puts 'rubocop is not available. Install the rubocop gem to run the lint tests.'
end

desc 'Run all pre-commit checks (lint, unit tests, profile validation)'
task pre_commit_checks: [:lint, :test, 'inspec:check']
