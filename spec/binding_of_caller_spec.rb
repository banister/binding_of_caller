require 'spec_helper'

puts "Testing binding_of_caller version #{BindingOfCaller::VERSION}..."
puts "Ruby version: #{RUBY_VERSION}"

RSpec.describe BindingOfCaller do
  describe "#of_caller" do
    it "fetches the immediate caller's binding when 0 is passed" do
      o = Object.new
      def o.a
        var = 1
        binding.of_caller(0).eval('var')
      end

      expect(o. a).to eq 1
    end

    it "fetches the parent of caller's binding when 1 is passed" do
      o = Object.new
      def o.a
        var = 1
        b
      end

      def o.b
        binding.of_caller(1).eval('var')
      end

      expect(o.a).to eq 1
    end

    it "modifies locals in the parent of caller's binding" do
      o = Object.new
      def o.a
        var = 1
        b
        var
      end

      def o.b
        binding.of_caller(1).eval('var = 20')
      end

      expect(o.a).to eq 20
    end

    it "raises an exception when retrieving an out-of-band binding" do
      o = Object.new
      def o.a
        binding.of_caller(100)
      end

      expect { o.a }.to raise_error(RuntimeError)
    end
  end

  describe "#callers" do
    before do
      @o = Object.new
    end

    it 'returns the first non-internal binding when using callers.first' do
      def @o.meth
        x = :a_local
        [binding.callers.first, binding.of_caller(0)]
      end

      b1, b2 = @o.meth
      expect(b1.eval("x")).to eq :a_local
      expect(b2.eval("x")).to eq :a_local
    end
  end

  describe "#frame_count" do
    it 'equals the binding callers.count' do
      expect(binding.frame_count).to eq binding.callers.count
    end
  end

  describe "#frame_descripton" do
    it 'can be called on ordinary binding without raising' do
      expect { binding.frame_description }.not_to raise_error
    end

    describe "when inside a block" do
      before { @binding = proc { binding.of_caller(0) }.call }

      it 'describes a block frame' do
        expect(@binding.frame_description).to match /block/
      end
    end

    describe "when inside an instance method" do
      before do
        o = Object.new
        def o.horsey_malone; binding.of_caller(0); end
        @binding = o.horsey_malone;
      end

      it 'describes a method frame with the method name' do
        expect(@binding.frame_description).to match /horsey_malone/
      end
    end

    describe "when inside a class definition" do
      before do
        class HorseyMalone
          @binding = binding.of_caller(0)
          def self.binding; @binding; end
        end
        @binding = HorseyMalone.binding
      end

      it 'describes a class frame' do
        expect(@binding.frame_description).to match /class/i
        Object.remove_const(:HorseyMalone)
      end
    end
  end

  describe "#frame_type" do
    it 'can be called on ordinary binding without raising' do
      expect { binding.frame_type }.not_to raise_error
    end

    describe "when inside a class definition" do
      before do
        class HorseyMalone
          @binding = binding.of_caller(0)
          def self.binding; @binding; end
        end
        @binding = HorseyMalone.binding
      end

      it 'returns :class' do
        expect(@binding.frame_type).to eq :class
      end
    end

    describe "when evaluated" do
      before { @binding = eval("binding.of_caller(0)") }

      it 'returns :eval' do
        expect(@binding.frame_type).to eq :eval
      end
    end

    describe "when inside a block" do
      before { @binding = proc { binding.of_caller(0) }.call }

      it 'returns :block' do
        expect(@binding.frame_type).to eq :block
      end
    end

    describe "when inside an instance method" do
      before do
        o = Object.new
        def o.a; binding.of_caller(0); end
        @binding = o.a;
      end

      it 'returns :method' do
        expect(@binding.frame_type).to eq :method
      end
    end
  end
end
