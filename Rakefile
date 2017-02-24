require 'bundler/gem_tasks'
require 'rake/testtask'

# load test by running rake test
Rake::TestTask.new do |t|
  t.name = 'test'
  t.libs << 'test' # load the test directory
  t.test_files = Dir['test/*test*.rb']
  t.verbose = true
end

task default: :spec
