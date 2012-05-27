require 'rdoc/task'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end

desc 'Run all unit tests for Union Station'
task :default => :test
