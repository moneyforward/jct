require "bundler/gem_tasks"
require "rake/testtask"

# slow test含めてすべてのテストを回す場合
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

# slow test用のrake taskは用意しない（CIでは1つずつrubyコマンドで叩くのでといらない）

task :default => :test
