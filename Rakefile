begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "netz"
    gem.rubyforge_project = "netz"
    gem.summary = %Q{Networking library for use in games.}
    gem.description = %Q{P2P Networking library for us in games. }
    gem.email = "shawn42@gmail.com"
    gem.homepage = "http://shawn42.github.com/netz"
    gem.authors = ["Shawn Anderson"]
    gem.add_development_dependency "rspec"
    gem.add_development_dependency "jeweler"
    gem.add_dependency 'gosu'
    gem.add_dependency 'bundler'
    gem.test_files = FileList['{spec,test}/**/*.rb']
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

# vim: syntax=Ruby
