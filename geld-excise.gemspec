# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'geld/excise/version'

Gem::Specification.new do |spec|
  spec.name          = "geld-excise"
  spec.version       = Geld::Excise::VERSION
  spec.authors       = ["Ryo Shibuya"]
  spec.email         = ["shibuya.ryo@moneyforward.co.jp"]

  spec.summary       = %q{Japanese excise tax calculator}
  spec.description   = %q{Japanese excise tax calculator}
  spec.homepage      = "https://github.com/moneyforward/geld-excise"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "> 1.10"
  spec.add_development_dependency "rake", "> 10.0"
end
