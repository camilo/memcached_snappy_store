# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.authors       = ["Camilo Lopez"]
  gem.email         = ["camilo@camilolopez.com"]
  gem.description   = %q{Memcached store that will compress all entries using snappy}
  gem.summary       = %q{Memcached store that will compress all entries using snappy}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "memcached_snappy_store"
  gem.require_paths = ["lib"]
  gem.version       = '0.0.1'
  gem.add_runtime_dependency "activesupport", "~>3.2.12"
  gem.add_runtime_dependency "snappy", "0.0.4"
  gem.add_development_dependency "i18n"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "minitest"
  gem.add_development_dependency "mocha"
  gem.add_development_dependency "timecop"
  gem.add_development_dependency "memcache"
  gem.add_development_dependency "memcache-client"
end
