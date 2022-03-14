require "bundler/gem_tasks"
require "rake/testtask"

# Run all tests including slow tests
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

Rake::TestTask.new(:no_slow_test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/geld/*_test.rb']
end

# No rake task for slow tests is prepared. (CI does not need it since ruby commands run them one at a time)

task :default => :test
