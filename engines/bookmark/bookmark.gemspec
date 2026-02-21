require_relative "lib/bookmark/version"

Gem::Specification.new do |spec|
  spec.name        = "bookmark"
  spec.version     = Bookmark::VERSION
  spec.authors     = [ "Console" ]
  spec.summary     = "북마크 플러그인"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "Rakefile"]
  end

  spec.add_dependency "rails", ">= 8.0"
  spec.add_dependency "hashids"
end
