dlext = Config::CONFIG['DLEXT']

if RUBY_ENGINE && RUBY_ENGINE == "ruby"
  require "binding_of_caller.#{dlext}"

elsif defined?(Rubinius)
  module BindingOfCaller
    module BindingExtensions

      def of_caller(n)
        bt = Rubinius::VM.backtrace(1 + n, true).first
        Binding.setup(
                      bt.variables,
                      bt.variables.method,
                      bt.static_scope
                      )
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
        ary = []
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
        "unknown"
      end

      def frame_description
        "no desc"
      end

    end
  end

  class ::Binding
    include BindingOfCaller::BindingExtensions
    extend BindingOfCaller::BindingExtensions
  end
end
