dlext = Config::CONFIG['DLEXT']
direc = File.dirname(__FILE__)

if RUBY_ENGINE && RUBY_ENGINE == "ruby"
  require "binding_of_caller.#{dlext}"

elsif defined?(Rubinius)
  module BindingOfCaller
    module BindingExtensions

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

      def frame_description
        @frame_description
      end

      def callers
        ary = []
        n = 0
        loop {
          begin
            ary << Binding.of_caller(n)
          rescue
            break
          end

          n += 1
        }

        ary
      end

      def frame_count
        n = 1
        loop {
          begin
            Binding.of_caller(n)
          rescue
            break
          end

          n += 1
        }

        n
      end

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
end
