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

  it "should fetch parent of caller's binding when 1 is passed" do
    o = Object.new
    def o.a
      var = 1
      b
    end

    def o.b
      binding.of_caller(1).eval('var')
    end

   o.a.should == 1
  end

  it "should modify locals in parent of caller's binding" do
    o = Object.new
    def o.a
      var = 1
      b
      var
    end

    def o.b
      binding.of_caller(1).eval('var = 20')
    end

   o.a.should == 20
  end

  it "should raise an exception when retrieving an out of band binding" do
    o = Object.new
    def o.a
      binding.of_caller(100)
    end

    lambda { o.a }.should.raise RuntimeError
  end
end

