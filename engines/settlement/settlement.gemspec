require_relative "lib/settlement/version"

Gem::Specification.new do |spec|
  spec.name        = "settlement"
  spec.version     = Settlement::VERSION
  spec.authors     = ["Console"]
  spec.summary     = "정산 플러그인"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "Rakefile"]
  end

  spec.add_dependency "rails", ">= 8.0"
end
