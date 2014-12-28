# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'typo_detector/version'

Gem::Specification.new do |spec|
  spec.name          = "typo_detector"
  spec.version       = TypoDetector::VERSION
  spec.authors       = ["Masafumi Yokoyama"]
  spec.email         = ["myokoym@gmail.com"]
  spec.summary       = %q{A detective tool for typo.}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/myokoym/typo_detector"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) {|f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency("bundler")
  spec.add_development_dependency("rake")
end
