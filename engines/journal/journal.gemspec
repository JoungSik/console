require_relative "lib/journal/version"

Gem::Specification.new do |spec|
  spec.name        = "journal"
  spec.version     = Journal::VERSION
  spec.authors     = ["Console"]
  spec.summary     = "포스트 플러그인"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "Rakefile"]
  end

  spec.add_dependency "rails", ">= 8.0"
end
