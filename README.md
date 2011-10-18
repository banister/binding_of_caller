binding_of_caller
===========

(C) John Mair (banisterfiend) 2011

_Retrieve the binding of a method's caller in MRI 1.9.2_

The `binding_of_caller` gem provides the `Binding#of_caller` method.

Using `binding_of_caller` we can grab bindings from higher up the call
stack and evaluate code in that context. Allows access to bindings arbitrarily far up the
call stack, not limited to just the immediate caller.

**Recommended for use only in debugging situations. Do not use this in production apps.**

**Only works in MRI Ruby 1.9.2**

* Install the [gem](https://rubygems.org/gems/binding_of_caller): `gem install binding_of_caller`
* See the [source code](http://github.com/banister/binding_of_caller)

Example: Modifying a local inside the caller of a caller
--------

    def a
      var = 10
      b
      puts var
    end

    def b
      c
    end

    def c
      binding.of_caller(2).eval('var = :hello')
    end

    a()

    # OUTPUT
    # => hello

Features and limitations
-------------------------

* Only works with MRI 1.9.2
* Broken in 1.9.3, support will hopefully be provided in the near
* future.
* Does not work in 1.8.7, but there is a well known (continuation-based) hack to get a `Binding#of_caller` there.

Contact
-------

Problems or questions contact me at [github](http://github.com/banister)


License
-------

(The MIT License)

Copyright (c) 2011 (John Mair)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
