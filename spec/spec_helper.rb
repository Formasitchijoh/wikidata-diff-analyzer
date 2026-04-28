# frozen_string_literal: true

require 'wikidata-diff-analyzer'

# Identify the test suite to wikidata.org so the anonymous-client rate
# limiter doesn't 429 us mid-run.
WikidataDiffAnalyzer.user_agent =
  "wikidata-diff-analyzer-specs/#{WikidataDiffAnalyzer::VERSION} " \
  '(https://github.com/WikiEducationFoundation/wikidata-diff-analyzer)'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
