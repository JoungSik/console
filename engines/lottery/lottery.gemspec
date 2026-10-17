require_relative "lib/lottery/version"

Gem::Specification.new do |spec|
  spec.name        = "lottery"
  spec.version     = Lottery::VERSION
  spec.authors     = [ "Console" ]
  spec.summary     = "동행복권 플러그인"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "Rakefile"]
  end

  spec.add_dependency "rails", ">= 8.0"
  spec.add_dependency "dh_lottery"
end
