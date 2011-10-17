unless Object.const_defined? :BindingOfCaller
  $:.unshift File.expand_path '../../lib', __FILE__
  require 'binding_of_caller'
  require 'binding_of_caller/version'
end

puts "Testing binding_of_caller version #{BindingOfCaller::VERSION}..."
puts "Ruby version: #{RUBY_VERSION}"

describe BindingOfCaller do
  it "should fetch immediate caller's binding when 0 is passed" do
    o = Object.new
    def o.a
      var = 1
      binding.of_caller(0).eval('var')
    end

   o. a.should == 1
  end
end

