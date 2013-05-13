# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'salesforce_bulk/version'

Gem::Specification.new do |gem|
  gem.name        = 'salesforce_bulk'
  gem.version     = SalesforceBulk::VERSION
  gem.authors     = ["Jorge Valdivia"]
  gem.email       = ["jorge@valdivia.me"]
  gem.homepage    = 'https://github.com/jorgevaldivia/salesforce_bulk'
  gem.summary     = %q{Ruby support for the Salesforce Bulk API}
  gem.description = %q{This gem provides a super simple interface for the Salesforce Bulk API. It provides support for insert, update, upsert, delete, and query.}

  gem.rubyforge_project = 'salesforce_bulk'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_dependency 'rake'
  gem.add_dependency 'nori', '~> 2.0'
  gem.add_dependency 'nokogiri', '~> 1.5'
  gem.add_development_dependency 'rspec', '~> 2.13'
  gem.add_development_dependency 'webmock', '~> 1.11'
end