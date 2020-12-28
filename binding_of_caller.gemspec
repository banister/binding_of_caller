require_relative 'lib/binding_of_caller/version'

Gem::Specification.new do |spec|
  spec.name          = "binding_of_caller"
  spec.version       = BindingOfCaller::VERSION
  spec.authors       = ["John Mair (banisterfiend)"]
  spec.email         = ["jrmair@gmail.com"]

  spec.summary       = %q{Retrieve the binding of a method's caller. Can also retrieve bindings even further up the stack.}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/banister/binding_of_caller"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.0.0")

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec)/}) }
  end

  spec.require_paths = ["lib"]

  spec.add_dependency "debug_inspector", ">= 0.0.1"
end
