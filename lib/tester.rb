require './binding_of_caller'

def a
  x = 1
  y = 2
  b()
end

def b
  proc do
    puts binding.of_caller(2).eval('__method__')
  end.call
end

a
