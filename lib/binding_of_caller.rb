dlext = RbConfig::CONFIG['DLEXT']

mri = defined?(RUBY_ENGINE) && RUBY_ENGINE == "ruby"

mri_2 = mri && RUBY_VERSION =~ /^2/

mri_3 = mri && RUBY_VERSION =~ /^3/

if mri_2 || mri_3
  require 'binding_of_caller/mri2'
elsif defined?(RUBY_ENGINE) && RUBY_ENGINE == "ruby"
  require "binding_of_caller.#{dlext}"
elsif defined?(Rubinius)
  require 'binding_of_caller/rubinius'
elsif defined?(JRuby)
  require 'binding_of_caller/jruby_interpreted'
end
