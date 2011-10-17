require './binding_of_caller'

outer = 10

class Z
  def z
    u = 10
    A.new.a
  end
end

class A
  def a
    y = 10
    B.new.b
  end
end

class B
  def b
    x = 10
    puts binding_of_caller(0).eval('local_variables')
    puts binding_of_caller(1).eval('local_variables')
    puts binding_of_caller(2).eval('local_variables')
    puts binding_of_caller(3).eval('local_variables')
    puts binding_of_caller(400).eval('local_variables')
  end
end

def a; b; end; def b; binding_of_caller(10); end; a;

# Z.new.z

# output:
# => x
# => y
# => u
# => outer
# Exception
