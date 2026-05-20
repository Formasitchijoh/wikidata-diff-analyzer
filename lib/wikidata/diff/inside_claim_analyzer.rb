# frozen_string_literal: true

require_relative 'reference_analyzer'
require_relative 'qualifier_analyzer'

class InsideClaimAnalyzer
  def self.isolate_inside_claim_differences(current_content, parent_content)
    added = []
    removed = []
    changed = []
    added_references = []
    removed_references = []
    changed_references = []
    added_qualifiers = []
    removed_qualifiers = []
    changed_qualifiers = []

    if current_content.nil?
      current_content_claims = {}
    else
      current_content_claims = current_content['claims']
      current_content_claims = {} unless current_content_claims.is_a?(Hash)
    end

    if parent_content.nil?
      parent_content_claims = {}
    else
      parent_content_claims = parent_content['claims']
      parent_content_claims = {} unless parent_content_claims.is_a?(Hash)
    end

    if parent_content.nil?
      current_content_claims.each do |claim_key, current_claims|
        current_claims.each_with_index do |current_claim, index|
          added << { key: claim_key, index: index }
          ReferenceAnalyzer.reference_updates(current_claim, added_references, claim_key, index)
          QualifierAnalyzer.qualifier_updates(current_claim, added_qualifiers, claim_key, index)
        end
      end
    else
      current_content_claims.each do |claim_key, current_claims|
        if parent_content_claims.key?(claim_key)
          parent_claims = parent_content_claims[claim_key]
          current_claims.each_with_index do |current_claim, index|
            parent_claim = parent_claims[index]
            if parent_claim.nil?
              added << { key: claim_key, index: index }
              ReferenceAnalyzer.reference_updates(current_claim, added_references, claim_key, index)
              QualifierAnalyzer.qualifier_updates(current_claim, added_qualifiers, claim_key, index)
            elsif current_claim != parent_claim
              changed << { key: claim_key, index: index }
              ref_result = ReferenceAnalyzer.handle_changed_references(
                current_claim, parent_claim, changed_references,
                added_references, removed_references, claim_key, index
              )
              added_references   = ref_result[:added_references]
              removed_references = ref_result[:removed_references]
              changed_references = ref_result[:changed_references]
              qual_result = QualifierAnalyzer.handle_changed_qualifiers(
                current_claim, parent_claim, changed_qualifiers,
                added_qualifiers, removed_qualifiers, claim_key, index
              )
              added_qualifiers   = qual_result[:added_qualifiers]
              removed_qualifiers = qual_result[:removed_qualifiers]
              changed_qualifiers = qual_result[:changed_qualifiers]
            end
          end
          parent_claims.each_with_index do |parent_claim, index|
            current_claim = current_claims[index]
            if current_claim.nil?
              removed << { key: claim_key, index: index }
              ReferenceAnalyzer.reference_updates(parent_claim, removed_references, claim_key, index)
              QualifierAnalyzer.qualifier_updates(parent_claim, removed_qualifiers, claim_key, index)
            end
          end
        else
          current_claims.each_with_index do |current_claim, index|
            added << { key: claim_key, index: index }
            ReferenceAnalyzer.reference_updates(current_claim, added_references, claim_key, index)
            QualifierAnalyzer.qualifier_updates(current_claim, added_qualifiers, claim_key, index)
          end
        end
      end

      parent_content_claims.each do |claim_key, parent_claims|
        parent_claims.each_with_index do |parent_claim, index|
          if current_content_claims.nil? || !current_content_claims.key?(claim_key)
            removed << { key: claim_key, index: index }
            ReferenceAnalyzer.reference_updates(parent_claim, removed_references, claim_key, index)
            QualifierAnalyzer.qualifier_updates(parent_claim, removed_qualifiers, claim_key, index)
          end
        end
      end
    end

    {
      added: added,
      removed: removed,
      changed: changed,
      added_references: added_references,
      removed_references: removed_references,
      changed_references: changed_references,
      added_qualifiers: added_qualifiers,
      removed_qualifiers: removed_qualifiers,
      changed_qualifiers: changed_qualifiers
    }
  end
end
