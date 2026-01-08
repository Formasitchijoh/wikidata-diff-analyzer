# frozen_string_literal: true

require File.expand_path('lib/wikidata-diff-analyzer/version', __dir__)

Gem::Specification.new do |spec|
  spec.name = 'wikidata-diff-analyzer'
  spec.version = WikidataDiffAnalyzer::VERSION
  spec.authors = ['Sulagna Saha']
  spec.email = ['saha23s@mtholyoke.edu']

  spec.summary = 'A Ruby gem for analyzing diffs between Wikidata items.'
  spec.description = 'This gem provides tools for analyzing diffs between Wikidata items,
  including retrieving the JSON representation of an item for a specific revision.'
  spec.homepage = 'https://github.com/WikiEducationFoundation/wikidata-diff-analyzer'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/WikiEducationFoundation/wikidata-diff-analyzer'
  spec.metadata['changelog_uri'] = 'https://github.com/WikiEducationFoundation/wikidata-diff-analyzer/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir['README.md', 'LICENSE',
                   'CHANGELOG.md', 'lib/**/*.rb',
                   'lib/**/*.rake',
                   'wikidata-diff-analyzer.gemspec', '.github/*.md',
                   'Gemfile', 'Rakefile']
  spec.extra_rdoc_files = ['README.md']
  spec.require_paths    = ['lib']

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.files.reject! { |f| File.extname(f) == '.gem' }

  # Adding the dependencies
  spec.add_runtime_dependency 'json', '~> 2.1'
  spec.add_runtime_dependency 'mediawiki_api'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.21'
end
