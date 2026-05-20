# frozen_string_literal: true

require './lib/wikidata/diff/language_analyzer'
require 'rspec'

RSpec.describe LanguageAnalyzer do
  describe '.isolate_language_differences' do
    # HTML: https://www.wikidata.org/w/index.php?diff=[REVISION_ID]
    # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=[REVISION_ID]&rvslots=main&rvprop=content|ids|comment&format=json

    it 'returns added_language and added_lexical_category when parent is nil (new lexeme)' do
      current = { 'language' => 'Q1860', 'lexicalCategory' => 'Q1084' }
      result = LanguageAnalyzer.isolate_language_differences(current, nil)
      expect(result[:added_language].length).to eq(1)
      expect(result[:changed_language].length).to eq(0)
      expect(result[:added_lexical_category].length).to eq(1)
      expect(result[:changed_lexical_category].length).to eq(0)
    end

    it 'returns changed_language when language field differs between revisions' do
      current = { 'language' => 'Q1860', 'lexicalCategory' => 'Q1084' }
      parent  = { 'language' => 'Q188',  'lexicalCategory' => 'Q1084' }
      result = LanguageAnalyzer.isolate_language_differences(current, parent)
      expect(result[:added_language].length).to eq(0)
      expect(result[:changed_language].length).to eq(1)
      expect(result[:added_lexical_category].length).to eq(0)
      expect(result[:changed_lexical_category].length).to eq(0)
    end

    it 'returns changed_lexical_category when lexicalCategory field differs between revisions' do
      current = { 'language' => 'Q1860', 'lexicalCategory' => 'Q24905' }
      parent  = { 'language' => 'Q1860', 'lexicalCategory' => 'Q1084' }
      result = LanguageAnalyzer.isolate_language_differences(current, parent)
      expect(result[:added_language].length).to eq(0)
      expect(result[:changed_language].length).to eq(0)
      expect(result[:added_lexical_category].length).to eq(0)
      expect(result[:changed_lexical_category].length).to eq(1)
    end

    it 'returns empty arrays when both language and lexicalCategory are unchanged' do
      current = { 'language' => 'Q1860', 'lexicalCategory' => 'Q1084' }
      parent  = { 'language' => 'Q1860', 'lexicalCategory' => 'Q1084' }
      result = LanguageAnalyzer.isolate_language_differences(current, parent)
      expect(result[:added_language].length).to eq(0)
      expect(result[:changed_language].length).to eq(0)
      expect(result[:added_lexical_category].length).to eq(0)
      expect(result[:changed_lexical_category].length).to eq(0)
    end

    it 'returns both changed_language and changed_lexical_category when both differ' do
      current = { 'language' => 'Q1860', 'lexicalCategory' => 'Q24905' } 
      parent  = { 'language' => 'Q188',  'lexicalCategory' => 'Q1084' }
      result = LanguageAnalyzer.isolate_language_differences(current, parent)
      expect(result[:added_language].length).to eq(0)
      expect(result[:changed_language].length).to eq(1)
      expect(result[:added_lexical_category].length).to eq(0)
      expect(result[:changed_lexical_category].length).to eq(1)
    end
  end
end
