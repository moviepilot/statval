require 'bundler/gem_tasks'

require 'rdoc/task'
require 'rspec'
require 'rspec/core/rake_task'

desc 'Run all rspecs'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.fail_on_error = true
  spec.verbose       = false
end

desc 'Run rdoc over project sources'
RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_files.include("lib/**/*.rb")
end

desc 'Run irb in project environment'
task :console do
  require 'irb'
  ARGV.clear
  IRB.start
end

task :doc => :rdoc
task :test => :spec
task :irb => :console
