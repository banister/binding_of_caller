require 'debug_inspector'

module BindingOfCaller
  module BindingExtensions
    # Retrieve the binding of the nth caller of the current frame.
    # @return [Binding]
    def of_caller(n)
      RubyVM::DebugInspector.open { |i| setup_binding_from_location(i, n+2) }
    rescue
      raise "No such frame, gone beyond end of stack!"
    end

    # Return bindings for all caller frames.
    # @return [Array<Binding>]
    def callers
      RubyVM::DebugInspector.open do |i|
        (2..(i.backtrace_locations.count-2)).map do |n|
          setup_binding_from_location(i, n)
        end
      end
    end

    # Number of parent frames available at the point of call.
    # @return [Fixnum]
    def frame_count
      RubyVM::DebugInspector.open(&:backtrace_locations).count - 3
    end

    # The type of the frame.
    # @return [Symbol]
    def frame_type
      if not @iseq.nil?
        # apparently the 9th element of the iseq array holds the frame type
        # ...not sure how reliable this is.
        @frame_type ||= @iseq.to_a[9]
      end
    end

    # The description of the frame.
    # @return [String]
    def frame_description
      if not @iseq.nil?
        @frame_description ||= @iseq.label
      end
    end

    protected

    def setup_binding_from_location(inspector, frame_number)
      binding = inspector.frame_binding(frame_number)

      if binding.nil?
        binding = setup_binding_from_location(inspector, frame_number + 1)
      end

      binding.instance_variable_set(:@iseq,
                                    inspector.frame_iseq(frame_number))

      binding
    end
  end
end

class ::Binding
  include BindingOfCaller::BindingExtensions
end
