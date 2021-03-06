# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'knowledge_camp/step/version'

Gem::Specification.new do |spec|
  spec.name          = "knowledge_camp_step"
  spec.version       = KnowledgeCamp::Step::VERSION
  spec.authors       = ["Kaid"]
  spec.email         = ["kaid@kaid.me"]
  spec.summary       = %q{Step model for knowledge-camp.}
  spec.description   = %q{Step model for knowledge-camp.}
  spec.homepage      = "https://github.com/mindpin/knowledge_camp_step"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "mongoid", ['< 6.0', '>= 4.0']

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rspec", "~> 3.0"
end
