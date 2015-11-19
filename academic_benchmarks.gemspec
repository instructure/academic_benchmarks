Gem::Specification.new do |s|
  s.name        = 'academic_benchmarks'
  s.version     = '0.0.1'
  s.date        = '2015-11-18'
  s.summary     = "A ruby api for accessing the Academic Benchmarks API"
  s.description = "A ruby api for accessing the Academic Benchmarks API.  " \
                  "A valid subscription with accompanying credentials " \
                  "will be required to access the API"
  s.authors     = ["Benjamin Porter"]
  s.email       = 'bporter@instructure.com'
  s.files       = ['lib/academic_benchmarks.rb'] + Dir['lib/academic_benchmarks/**/*']
  s.homepage    = 'https://github.com/instructure/academic_benchmarks'
  s.license     = 'GPL'

  s.add_runtime_dependency 'httparty', '~> 0.13'
  s.add_runtime_dependency "activesupport", "~> 4.2"

  s.add_development_dependency "byebug", '~> 4.0'
  s.add_development_dependency "rspec", "~> 3.1"
  s.add_development_dependency "awesome_print", "~> 1.6"
end
