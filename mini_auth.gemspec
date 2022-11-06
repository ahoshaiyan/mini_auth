# frozen_string_literal: true

require_relative "lib/mini_auth/version"

Gem::Specification.new do |spec|
  spec.name = "mini_auth"
  spec.version = MiniAuth::VERSION
  spec.authors = ["Ali Alhoshaiyan"]
  spec.email = ["ahoshaiyan@fastmail.com"]

  spec.summary = "Pragmatic authentication for Ruby on Rails."
  spec.description = "MiniAuth is a pragmatic authentication gem for Rails that is inspired by Laravel's guards pattern that provides highly customizable and simple authentication for your web applications and APIs."
  spec.homepage = "https://github.com/ahoshaiyan/mini_auth"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ahoshaiyan/mini_auth"
  spec.metadata["changelog_uri"] = "https://github.com/ahoshaiyan/mini_auth"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "activesupport"
  spec.add_dependency "activemodel"
  spec.add_dependency "actionpack"
  spec.add_dependency "bcrypt"
end
