Gem::Specification.new do |s|
  s.name        = 'academic_benchmarks'
  s.version     = '1.1.0'
  s.date        = '2016-11-23'
  s.summary     = "A ruby api for accessing the Academic Benchmarks API"
  s.description = "A ruby api for accessing the Academic Benchmarks API.  " \
                  "A valid subscription with accompanying credentials " \
                  "will be required to access the API"
  s.authors     = ["Benjamin Porter", "Augusto Callejas"]
  s.email       = ['bporter@instructure.com', 'acallejas@instructure.com']
  s.files       = ['lib/academic_benchmarks.rb'] + Dir['lib/academic_benchmarks/**/*']
  s.homepage    = 'https://github.com/instructure/academic_benchmarks'
  s.license     = 'AGPL-3.0'

  s.add_runtime_dependency 'httparty', '~> 0.13'
  s.add_runtime_dependency "activesupport", ">= 3.2.22", "< 6.1"

  s.add_development_dependency "hash_dig_and_collect", "~> 0.0.1"
  s.add_development_dependency "rake", "~> 12.0"
  s.add_development_dependency "vcr", "~> 3.0"
  s.add_development_dependency "rspec", "~> 3.4"
  s.add_development_dependency "byebug"
  s.add_development_dependency "webmock", "~> 3.5"
  s.add_development_dependency "rubocop", "~> 0.49"
  s.add_development_dependency "rubocop-rspec", "~> 1.3"
  s.add_development_dependency "awesome_print", "~> 1.6"
end
