require 'rake'

Gem::Specification.new do |s|
  s.name         =  'union_station'
  s.version      =  '0.2.0'
  s.date         =  '2012-06-01'
  s.license	 =  'MIT'
  s.homepage     =  'http://stratosphe.re'
  s.summary      =  'A simple and powerful event broadcast daemon'
  s.description  =  'Union Station takes event sources, multiplexes them, and streams them out to clients.'
  s.authors      =  ['Morgan Jones']
  s.email        =  'integ3rs@gmail.com'
  s.files        =  FileList['lib/union_station.rb', 'lib/us/*.rb', 'lib/us/protocol/*.rb'].to_a
  s.has_rdoc     = true
  s.add_dependency 'json'
  s.add_dependency 'eventmachine'
  s.add_dependency 'uuidtools'
end