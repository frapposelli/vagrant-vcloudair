require 'rubygems'
require 'bundler/setup'
require 'rspec/core/rake_task'

# Immediately sync all stdout so that tools like buildbot can
# immediately load in the output.
$stdout.sync = true
$stderr.sync = true

# Change to the y of this file.
Dir.chdir(File.expand_path('../', __FILE__))

Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new

task :default => 'spec'