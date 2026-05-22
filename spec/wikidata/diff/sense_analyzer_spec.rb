# frozen_string_literal: true

require './lib/wikidata/diff/sense_analyzer'
require 'rspec'

RSpec.describe SenseAnalyzer do
  describe '.isolate_senses_differences' do
    # Sense with one claim that has one reference and one qualifier.
    let(:sense_with_ref_and_qual) do
      {
        'id' => 'L1-S1',
        'glosses' => { 'en' => { 'language' => 'en', 'value' => 'a flat cooking utensil' } },
        'claims' => {
          'P5137' => [
            {
              'mainsnak' => { 'snaktype' => 'value', 'property' => 'P5137' },
              'references' => [
                { 'snaks' => { 'P248' => [{ 'snaktype' => 'value', 'property' => 'P248' }] } }
              ],
              'qualifiers' => {
                'P580' => [{ 'snaktype' => 'value', 'property' => 'P580', 'datavalue' => { 'value' => '2020' } }]
              }
            }
          ]
        }
      }
    end

    # Same sense but with a different gloss — triggers current_sense != parent_sense
    # while leaving claims, references, and qualifiers identical.
    let(:sense_same_claims_different_gloss) do
      {
        'id' => 'L1-S1',
        'glosses' => { 'en' => { 'language' => 'en', 'value' => 'a cooking tool' } },
        'claims' => {
          'P5137' => [
            {
              'mainsnak' => { 'snaktype' => 'value', 'property' => 'P5137' },
              'references' => [
                { 'snaks' => { 'P248' => [{ 'snaktype' => 'value', 'property' => 'P248' }] } }
              ],
              'qualifiers' => {
                'P580' => [{ 'snaktype' => 'value', 'property' => 'P580', 'datavalue' => { 'value' => '2020' } }]
              }
            }
          ]
        }
      }
    end

    # changed sense: previously passed nil as parent to InsideClaimAnalyzer,
    # so all existing claims were treated as newly added. Now passes parent_sense,
    # so unchanged claims/references/qualifiers produce zero deltas.
    it 'does not overcount senseclaims/references/qualifiers when only the gloss changed' do
      current = { 'senses' => [sense_with_ref_and_qual] }
      parent  = { 'senses' => [sense_same_claims_different_gloss] }
      result  = SenseAnalyzer.isolate_senses_differences(current, parent)

      expect(result[:changed_senses].length).to eq(1)
      expect(result[:changed_glosses].length).to eq(1)
      # Claims, references, and qualifiers are identical — none should be counted.
      expect(result[:added_senseclaims].length).to eq(0)
      expect(result[:added_sense_references].length).to eq(0)
      expect(result[:added_sense_qualifiers].length).to eq(0)
    end

    # removed sense: previously passed (nil, nil) to InsideClaimAnalyzer
    # because current_sense was already nil, so removals were silently skipped.
    # Now passes (nil, parent_sense), which correctly tallies removed references/qualifiers.
    it 'counts removed_sense_references and removed_sense_qualifiers when a sense is removed' do
      current = { 'senses' => [] }
      parent  = { 'senses' => [sense_with_ref_and_qual] }
      result  = SenseAnalyzer.isolate_senses_differences(current, parent)

      expect(result[:removed_senses].length).to eq(1)
      expect(result[:removed_senseclaims].length).to eq(1)
      expect(result[:removed_sense_references].length).to eq(1)
      expect(result[:removed_sense_qualifiers].length).to eq(1)
    end
  end
end
