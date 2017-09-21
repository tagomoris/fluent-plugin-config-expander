# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-config-expander"
  gem.version       = "1.1.0"
  gem.authors       = ["TAGOMORI Satoshi"]
  gem.email         = ["tagomoris@gmail.com"]
  gem.description   = %q{This plugin provides directives for loop extraction}
  gem.summary       = %q{Fluentd plugin to serve some DSL directives in configuration}
  gem.homepage      = "https://github.com/tagomoris/fluent-plugin-config-expander"
  gem.license       = "Apache-2.0"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "fluentd", ">= 0.14.0"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "test-unit", "~> 3.1"
end
