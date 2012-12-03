dlext = RbConfig::CONFIG['DLEXT']
direc = File.dirname(__FILE__)

if defined?(RUBY_ENGINE) && RUBY_ENGINE == "ruby" && RUBY_VERSION =~ /2\.0/
  require 'binding_of_caller/ruby2'
elsif defined?(RUBY_ENGINE) && RUBY_ENGINE == "ruby"
  require "binding_of_caller.#{dlext}"
elsif defined?(Rubinius)
  require 'binding_of_caller/rubinius'
end
