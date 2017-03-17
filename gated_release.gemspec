# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gated_release/version'

Gem::Specification.new do |spec|
  spec.name          = "gated_release"
  spec.version       = GatedRelease::VERSION
  spec.authors       = ["David Carlin", "Gonzalo Bulnes Guilpain"]
  spec.email         = ["davich@gmail.com", "gon.bulnes@gmail.com"]
  spec.summary       = %q{Allow split code paths.}
  spec.description   = %q{Gated releases will let you launch your new feature behind a toggle switch that doesn't require a redeploy.}
  spec.homepage      = "http://www.github.com/redbubble/gated_release"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|vendor|bin)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 4.0", "< 6"
  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "sqlite3", "~> 1.3"
  spec.add_development_dependency "database_cleaner", "~> 1.5"
  spec.add_development_dependency "generator_spec", "~> 0.9.0"
end
