require 'spec/rake/spectask'
require 'lib/console_tweet/version'
 
task :build => :test do
  system "gem build console_tweet.gemspec"
end

task :release => :build do
  # tag and push
  system "git tag v#{ConsoleTweet::VERSION}"
  system "git push origin --tags"
  # push the gem
  system "gem push ice_cube-#{ConsoleTweet::VERSION}.gem"
end
 
Spec::Rake::SpecTask.new(:test) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  fail_on_error = true # be explicit
end
 
Spec::Rake::SpecTask.new(:rcov) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.rcov = true
  fail_on_error = true # be explicit
end
