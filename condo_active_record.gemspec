$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "condo_active_record/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "condo_active_record"
  s.version     = CondoActiveRecord::VERSION
  s.authors     = ["Stephen von Takach"]
  s.email       = ["steve@cotag.me"]
  s.homepage    = "http://cotag.me/"
  s.summary     = "ActiveRecord backend for the Condo project."
  s.description = "Provides database storage and migrations though utilising ActiveRecord."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LGPL3-LICENSE", "Rakefile", "README.textile"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails"
  s.add_dependency "condo"

  s.add_development_dependency "sqlite3"
end
