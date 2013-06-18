require 'rubygems'
require File.dirname(__FILE__) + '/lib/console_tweet/version'

spec = Gem::Specification.new do |s|

  s.name = 'console_tweet'
  s.author = 'John Crepezzi'
  s.add_development_dependency('rspec')
  s.add_dependency('twitter_oauth', '>= 0.4.9')
  s.description = 'CLI Twitter Client - with OAuth'
  s.email = 'john@crepezzi.com'
  s.executables = 'twitter'
  s.files = Dir['lib/**/*.rb']
  s.has_rdoc = true
  s.homepage = 'http://seejohnrun.github.com/console_tweet/'
  s.platform = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.summary = 'CLI Twitter Client'
  s.test_files = Dir.glob('spec/*.rb')
  s.version = ConsoleTweet::VERSION
  s.rubyforge_project = "console_tweet"

end
