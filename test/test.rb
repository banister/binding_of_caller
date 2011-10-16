direc = File.dirname(__FILE__)

require 'rubygems'
require "#{direc}/../lib/binding_of_caller"
require 'bacon'

puts "Testing binding_of_caller version #{BindingOfCaller::VERSION}..." 
puts "Ruby version: #{RUBY_VERSION}"

describe BindingOfCaller do
end

