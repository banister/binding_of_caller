require 'debug_inspector'

module BindingOfCaller
  module BindingExtensions

    # Retrieve the binding of the nth caller of the current frame.
    # @return [Binding]
    def of_caller(n)
      b = nil

      j = n
      loop do
        b = RubyVM::DebugInspector.open do |i|
          i.frame_binding(j + 4)
        end
        break if b
        j += 1
      end

      b
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
         rescue ArgumentError
          break
        end
        n += 1
      end
      ary.drop(3)
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
