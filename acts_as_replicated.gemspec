# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "acts_as_replicated/version"

Gem::Specification.new do |gem|
  gem.name        = "acts_as_replicated"
  gem.version     = ActsAsReplicated::VERSION
  gem.authors     = ["Eugene Korpan"]
  gem.email       = ["korpan.eugene@gmail.com"]
  gem.homepage    = ""
  gem.summary     = %q{TODO: Write a gem summary}
  gem.description = %q{TODO: Write a gem description}

  gem.rubyforge_project = "rails-ldap"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_dependency "net-ldap"
end
