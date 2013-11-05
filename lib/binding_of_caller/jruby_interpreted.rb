class org::jruby::runtime::ThreadContext
  java_import org.jruby.runtime.Binding
  java_import org.jruby.RubyBinding
  java_import org.jruby.RubyInstanceConfig::CompileMode

  field_accessor :frameStack, :frameIndex,
    :scopeStack, :scopeIndex,
    :backtrace, :backtraceIndex

  def binding_of_caller(index)
    unless JRuby.runtime.instance_config.compile_mode == CompileMode::OFF
      raise RuntimeError, "caller binding only supported in interpreter"
    end

    index += 1 # always omit this frame

    raise RuntimeError, "Invalid frame, gone beyond end of stack!" if index > frameIndex

    frame = frameStack[frameIndex - index]

    return binding_of_caller(index - 1) if index > scopeIndex

    scope = scopeStack[scopeIndex - index]
    element = backtrace[backtraceIndex - index]

    binding = Binding.new(frame, scope.static_scope.module, scope, element.clone)

    JRuby.dereference(RubyBinding.new(JRuby.runtime, Binding, binding))
  end
end

module BindingOfCaller
  module BindingExtensions
    def of_caller(index = 1)
      index += 1 # always omit this frame
      JRuby.runtime.current_context.binding_of_caller(index)
    end

    def callers
      ary = []
      n = 2
      loop do
        ary << of_caller(n) rescue break
        n += 1
      end
      ary
    end

    def frame_count
      callers.count - 1
    end
  end
end

class ::Binding
  include BindingOfCaller::BindingExtensions
  extend BindingOfCaller::BindingExtensions
end

class Java::OrgJrubyRuntime::Binding
  def eval(code)
    Kernel.eval code, self
  end
end
