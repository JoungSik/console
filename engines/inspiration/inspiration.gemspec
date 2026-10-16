require_relative "lib/inspiration/version"

Gem::Specification.new do |spec|
  spec.name        = "inspiration"
  spec.version     = Inspiration::VERSION
  spec.authors     = [ "Console" ]
  spec.summary     = "아이디어 꾸러미 플러그인"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "Rakefile"]
  end

  spec.add_dependency "rails", ">= 8.0"
end
