require_relative "lib/todo/version"

Gem::Specification.new do |spec|
  spec.name        = "todo"
  spec.version     = Todo::VERSION
  spec.authors     = ["Console"]
  spec.summary     = "할 일 목록 플러그인"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "Rakefile"]
  end

  spec.add_dependency "rails", ">= 8.0"
end
