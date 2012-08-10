# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "typecaster/version"

Gem::Specification.new do |s|
  s.name        = "typecaster"
  s.version     = Typecaster::VERSION
  s.authors     = ["Ricardo H."]
  s.email       = ["ricardohsd@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Ease create plain old ruby object with formatted values}
  s.description = %q{Typecaster make easy the job of create plain old ruby object with formatted values}

  s.rubyforge_project = "typecaster"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec", ">= 2.8.0"
  s.add_development_dependency 'rake', '>= 0.8.7'
end
