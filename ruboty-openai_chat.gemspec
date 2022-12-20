# frozen_string_literal: true

require_relative "lib/ruboty/openai_chat/version"

Gem::Specification.new do |spec|
  spec.name = "ruboty-openai_chat"
  spec.version = Ruboty::OpenAIChat::VERSION
  spec.authors = ["Tomoya Chiba"]
  spec.email = ["tomo.asleep@gmail.com"]
  spec.license = "Apache-2.0"

  spec.summary = "OpenAI responds to given message if any other handler does not matches."
  spec.homepage = "https://github.com/tomoasleep/ruboty-openai_chat"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = File.join(spec.homepage, "blob/main/CHANGELOG.md")

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
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "ruboty"
  spec.add_dependency "ruby-openai", "~> 2.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
