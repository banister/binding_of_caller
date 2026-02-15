require_relative 'lib/binding_of_caller/version'

Gem::Specification.new do |spec|
  spec.name          = "binding_of_caller"
  spec.version       = BindingOfCaller::VERSION
  spec.authors       = ["John Mair (banisterfiend)"]
  spec.email         = ["jrmair@gmail.com"]

  spec.summary       = %q{Retrieve the binding of a method's caller, or further up the stack.}
  spec.description   = <<-TXT
Provides the Binding#of_caller method.

Using binding_of_caller we can grab bindings from higher up the call stack and evaluate code in that context.
Allows access to bindings arbitrarily far up the call stack, not limited to just the immediate caller.

Recommended for use only in debugging situations. Do not use this in production apps.
TXT
  spec.homepage      = "https://github.com/banister/binding_of_caller"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata = {
    "changelog_uri"  => "https://github.com/banister/binding_of_caller/releases",
  }
  
  spec.files         = Dir.glob('lib/**/*') + ['LICENSE', 'README.md']

  spec.require_paths = ["lib"]

  spec.add_dependency "debug_inspector", ">= 1.2.0"
end
