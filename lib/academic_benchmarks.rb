require 'httparty'
require 'json'
require 'base64'
require 'openssl'

begin
  require 'byebug'
rescue LoadError => e
end

Gem.find_files("academic_benchmarks/**/*.rb").each do |path|
  require path.gsub(/\.rb$/, '')
end
