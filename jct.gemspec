# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jct/version'

Gem::Specification.new do |spec|
  spec.name          = "jct"
  spec.version       = Jct::VERSION
  spec.licenses      = ['Apache-2.0']
  spec.authors       = ["Money Forward, Inc."]
  spec.email         = ["shibuya.ryo@moneyforward.co.jp"]

  spec.summary       = %q{Japanese excise tax calculator}
  spec.description   = %q{Japanese excise tax calculator}
  spec.homepage      = "https://github.com/moneyforward/jct"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "> 1.10"
  spec.add_development_dependency "rake", "> 10.0"
end
