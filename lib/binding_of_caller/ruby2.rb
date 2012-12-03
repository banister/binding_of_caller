require 'binding_of_caller/debug_inspector'

module BindingOfCaller
  module BindingExtensions

    # Retrieve the binding of the nth caller of the current frame.
    # @return [Binding]
    def of_caller(n)

      b = nil
      bt_loc = nil
      RubyVM::DebugInspector.open do |i|
        b = i.frame_binding(n)
        bt_loc = i.backtrace_locations[n]
      end
      
      b.instance_variable_set(:@frame_description, bt_loc)

      b
    rescue
      raise RuntimeError, "Invalid frame, gone beyond end of stack!"
    end

    # The description of the frame.
    # @return [String]
    def frame_description
      @frame_description
    end

    # Return bindings for all caller frames.
    # @return [Array<Binding>]
    def callers
      ary = []
      n = 0
      loop do
        begin
          ary << binding.of_caller(n)
        rescue
          break
        end
        n += 1
      end
      ary.drop_while do |v|
        !(v.frame_type == :method && v.eval("__method__") == :callers)
      end.drop(1)
    end

    # Number of parent frames available at the point of call.
    # @return [Fixnum]
    def frame_count
      callers.size - 1
    end

    # The type of the frame.
    # @return [Symbol]
    def frame_type
      "N/A"
    end

  end
end


class ::Binding
  include BindingOfCaller::BindingExtensions
end
