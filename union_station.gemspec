Gem::Specification.new do |s|
  s.name         =  'union_station'
  s.version      =  '0.1.0'
  s.date         =  '2012-05-24'
  s.license	 =  'MIT'
  s.homepage     =  'http://stratosphe.re'
  s.summary      =  'A simple and powerful event broadcast daemon'
  s.description  =  'Union Station takes event sources, multiplexes them in the Event Transceiver, and streams them out to clients.'
  s.authors      =  ['Morgan Jones']
  s.email        =  'integ3rs@gmail.com'
  s.files        =  FileList['lib/union_station.rb', 'lib/union_station/*.rb'].to_a
  s.has_rdoc     = true
  s.dependencies = ['json', 'eventmachine', 'em-websocket', 'uuidtools']
end