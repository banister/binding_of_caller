module BindingOfCaller
  module BindingExtensions

    # Retrieve the binding of the nth caller of the current frame.
    # @return [Binding]
    def of_caller(n)
      bt = Rubinius::VM.backtrace(1 + n, true).first

      b = Binding.setup(
                        bt.variables,
                        bt.variables.method,
                        bt.static_scope,
                        bt.variables.self,
                        bt
                        )

      b.instance_variable_set(:@frame_description, bt.describe)

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
          ary << Binding.of_caller(n)
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
      case self.variables.method.metadata.to_a.first.to_s
      when /block/
        :block
      when /eval/
        :eval
      else
        if frame_description =~ /__(?:class|module)_init__/
          :class
        else
          :method
        end
      end
    end

  end
end

class ::Binding
  include BindingOfCaller::BindingExtensions
  extend BindingOfCaller::BindingExtensions
end
