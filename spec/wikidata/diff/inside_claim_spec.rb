# frozen_string_literal: true

require './lib/wikidata/diff/inside_claim_analyzer'
require 'rspec'

RSpec.describe InsideClaimAnalyzer do
  describe '.isolate_inside_claim_differences' do
    let(:claim_with_reference) do
      {
        'claims' => {
          'P31' => [
            {
              'mainsnak' => { 'snaktype' => 'value', 'property' => 'P31' },
              'references' => [
                { 'snaks' => { 'P248' => [{ 'snaktype' => 'value', 'property' => 'P248' }] } }
              ]
            }
          ]
        }
      }
    end

    let(:claim_with_qualifier) do
      {
        'claims' => {
          'P31' => [
            {
              'mainsnak' => { 'snaktype' => 'value', 'property' => 'P31' },
              'qualifiers' => {
                'P580' => [{ 'snaktype' => 'value', 'property' => 'P580', 'datavalue' => { 'value' => '2020' } }]
              }
            }
          ]
        }
      }
    end

    let(:claim_no_ref_no_qual) do
      {
        'claims' => {
          'P31' => [
            { 'mainsnak' => { 'snaktype' => 'value', 'property' => 'P31' } }
          ]
        }
      }
    end

    let(:empty_claims) { { 'claims' => {} } }

    it 'counts added_references when a new claim with a reference is added and parent is nil' do
      result = InsideClaimAnalyzer.isolate_inside_claim_differences(claim_with_reference, nil)
      expect(result[:added].length).to eq(1)
      expect(result[:added_references].length).to eq(1)
      expect(result[:added_qualifiers].length).to eq(0)
    end

    it 'counts added_qualifiers when a new claim with a qualifier is added and parent is nil' do
      result = InsideClaimAnalyzer.isolate_inside_claim_differences(claim_with_qualifier, nil)
      expect(result[:added].length).to eq(1)
      expect(result[:added_qualifiers].length).to eq(1)
      expect(result[:added_references].length).to eq(0)
    end

    it 'counts removed_references when a claim with a reference is removed' do
      result = InsideClaimAnalyzer.isolate_inside_claim_differences(empty_claims, claim_with_reference)
      expect(result[:removed].length).to eq(1)
      expect(result[:removed_references].length).to eq(1)
    end

    it 'counts removed_qualifiers when a qualifier is removed from an existing claim' do
      result = InsideClaimAnalyzer.isolate_inside_claim_differences(claim_no_ref_no_qual, claim_with_qualifier)
      expect(result[:changed].length).to eq(1)
      expect(result[:removed_qualifiers].length).to eq(1)
      expect(result[:added_qualifiers].length).to eq(0)
    end

    it 'counts added_references when a reference is added to an existing claim' do
      result = InsideClaimAnalyzer.isolate_inside_claim_differences(claim_with_reference, claim_no_ref_no_qual)
      expect(result[:changed].length).to eq(1)
      expect(result[:added_references].length).to eq(1)
      expect(result[:removed_references].length).to eq(0)
    end

    it 'counts added_qualifiers when a qualifier is added to an existing claim' do
      result = InsideClaimAnalyzer.isolate_inside_claim_differences(claim_with_qualifier, claim_no_ref_no_qual)
      expect(result[:changed].length).to eq(1)
      expect(result[:added_qualifiers].length).to eq(1)
      expect(result[:removed_qualifiers].length).to eq(0)
    end

    it 'returns all zeros when nothing changed' do
      result = InsideClaimAnalyzer.isolate_inside_claim_differences(claim_with_reference, claim_with_reference)
      expect(result[:added].length).to eq(0)
      expect(result[:removed].length).to eq(0)
      expect(result[:changed].length).to eq(0)
      expect(result[:added_references].length).to eq(0)
      expect(result[:removed_references].length).to eq(0)
      expect(result[:changed_references].length).to eq(0)
      expect(result[:added_qualifiers].length).to eq(0)
      expect(result[:removed_qualifiers].length).to eq(0)
      expect(result[:changed_qualifiers].length).to eq(0)
    end
  end
end
