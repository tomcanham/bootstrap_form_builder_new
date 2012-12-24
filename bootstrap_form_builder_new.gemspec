$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "bootstrap_form_builder/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "bootstrap_form_builder_new"
  s.version     = BootstrapFormBuilder::VERSION
  s.authors     = ["Tom Canham"]
  s.email       = ["alphasimian@gmail.com"]
  s.homepage    = "https://github.com/tomcanham"
  s.summary     = "A simple Twitter Bootstrap Form Builder helper."
  s.description = "Adds a Twitter Bootstrap FormBuilder."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 3.2"
  s.add_development_dependency "capybara"
  s.add_development_dependency "rspec-rails"
end
