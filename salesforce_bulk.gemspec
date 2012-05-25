# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "salesforce_bulk/version"

Gem::Specification.new do |s|
  s.name        = "salesforce_bulk"
  s.version     = SalesforceBulk::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jorge Valdivia","Javier Julio"]
  s.email       = ["jorge@valdivia.me","jjfutbol@gmail.com"]
  s.homepage    = "https://github.com/jorgevaldivia/salesforce_bulk"
  s.summary     = %q{Ruby support for the Salesforce Bulk API}
  s.description = %q{This gem is a simple interface to the Salesforce Bulk API providing support for insert, update, upsert, delete, and query.}

  s.rubyforge_project = "salesforce_bulk"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "xml-simple"

  s.add_development_dependency "mocha"
  s.add_development_dependency "shoulda"

end
