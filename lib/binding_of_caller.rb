# binding_of_caller.rb
# (C) John Mair (banisterfiend); MIT license

direc = File.dirname(__FILE__)

require "#{direc}/binding_of_caller/version"

begin
  if RUBY_VERSION =~ /1.9/
    require "#{direc}/1.9/binding_of_caller"
  else
    require "#{direc}/1.8/binding_of_caller"
  end
rescue LoadError => e
  require "rbconfig"
  dlext = Config::CONFIG['DLEXT']
  require "#{direc}/binding_of_caller.#{dlext}"
end

module BindingOfCaller
end  

