# encoding: utf-8

require 'rubygems'
require 'bundler'
require './lib/replicant/version'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "replicant-adb"
  gem.version = Replicant::VERSION
  gem.homepage = "https://github.com/mttkay/replicant"
  gem.license = "MIT"
  gem.summary = "A REPL for the Android Debug Bridge"
  gem.description = "replicant is an interactive shell (a REPL) for ADB, the Android Debug Bridge"
  gem.email = "m.kaeppler@gmail.com"
  gem.authors = ["Matthias Kaeppler"]
  gem.files = ["lib/**/*.rb", "LICENSE.txt"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_spec.rb'
  test.verbose = true
end

task :default => :test

