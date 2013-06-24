# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "salesforce_bulk/version"

Gem::Specification.new do |s|
  s.name        = "salesforce_bulk"
  s.version     = SalesforceBulk::VERSION
  s.authors     = ["Jorge Valdivia"]
  s.email       = ["jorge@valdivia.me"]
  s.homepage    = "https://github.com/jorgevaldivia/salesforce_bulk"
  s.summary     = %q{Ruby support for the Salesforce Bulk API}
  s.description = %q{This gem provides a super simple interface for the Salesforce Bulk API. It provides support for insert, update, upsert, delete, and query.}

  s.rubyforge_project = "salesforce_bulk"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"

  s.add_dependency "xml-simple"
  s.add_dependency "databasedotcom-rails"

end
