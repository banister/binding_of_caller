require "binding_of_caller/version"

if defined?(RUBY_ENGINE) && RUBY_ENGINE == "ruby"
  if RUBY_VERSION =~ /^2/
    require 'binding_of_caller/mri2'
  else
    puts "This version of binding_of_caller doesn't support this version of Ruby"
  end
elsif defined?(Rubinius)
  require 'binding_of_caller/rubinius'
elsif defined?(JRuby)
  require 'binding_of_caller/jruby_interpreted'
end
