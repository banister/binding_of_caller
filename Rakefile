dlext = Config::CONFIG['DLEXT']

$:.unshift 'lib'

PROJECT_NAME = "binding_of_caller"

require 'rake/clean'
require 'rake/gempackagetask'
require "#{PROJECT_NAME}/version"

CLOBBER.include("**/*.#{dlext}", "**/*~", "**/*#*", "**/*.log", "**/*.o")
CLEAN.include("ext/**/*.#{dlext}", "ext/**/*.log", "ext/**/*.o",
              "ext/**/*~", "ext/**/*#*", "ext/**/*.obj", "**/*#*", "**/*#*.*",
              "ext/**/*.def", "ext/**/*.pdb", "**/*_flymake*.*", "**/*_flymake")

def apply_spec_defaults(s)
  s.name = PROJECT_NAME
  s.summary = "FIX ME"
  s.version = BindingOfCaller::VERSION
  s.date = Time.now.strftime '%Y-%m-%d'
  s.author = "John Mair (banisterfiend)"
  s.email = 'jrmair@gmail.com'
  s.description = s.summary
  s.require_path = 'lib'
  s.add_development_dependency("bacon","~>1.1.0")
  s.homepage = "http://banisterfiend.wordpress.com"
  s.has_rdoc = 'yard'
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- test/*`.split("\n")
end

desc "Run tests"
task :test do
  sh "bacon -Itest -rubygems test.rb -q"
end

namespace :ruby do
  spec = Gem::Specification.new do |s|
    apply_spec_defaults(s)
    s.platform = Gem::Platform::RUBY
    s.extensions = ["ext/#{PROJECT_NAME}/extconf.rb"]
  end

  Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_zip = false
    pkg.need_tar = false
  end
end

desc "build the biinaries"
task :compile do
  chdir "./ext/#{PROJECT_NAME}/" do
    sh "ruby extconf.rb"
    sh "make clean"
    sh "make"
    sh "cp *.#{dlext} ../../lib/"
  end
end

desc "build all platform gems at once"
task :gems => [:clean, :rmgems, "ruby:gem"]

desc "remove all platform gems"
task :rmgems => ["ruby:clobber_package"]

desc "build and push latest gems"
task :pushgems => :gems do
  chdir("#{direc}/pkg") do
    Dir["*.gem"].each do |gemfile|
      sh "gem push #{gemfile}"
    end
  end
end
