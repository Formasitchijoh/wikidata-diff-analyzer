# frozen_string_literal: true

require_relative 'gloss_analyzer'
require_relative 'inside_claim_analyzer'

class SenseAnalyzer
  def self.isolate_senses_differences(current_content, parent_content)
    added_senses = []
    removed_senses = []
    changed_senses = []
    added_glosses = []
    removed_glosses = []
    changed_glosses = []
    added_senseclaims = []
    removed_senseclaims = []
    changed_senseclaims = []
    added_sense_references = []
    removed_sense_references = []
    changed_sense_references = []
    added_sense_qualifiers = []
    removed_sense_qualifiers = []
    changed_sense_qualifiers = []

    current_content_senses = current_content['senses'] if current_content
    parent_content_senses  = parent_content['senses']  if parent_content

    if !current_content_senses.is_a?(Array) || !parent_content_senses.is_a?(Array)
      return {
        added_senses: added_senses,
        removed_senses: removed_senses,
        changed_senses: changed_senses,
        added_glosses: added_glosses,
        removed_glosses: removed_glosses,
        changed_glosses: changed_glosses,
        added_senseclaims: added_senseclaims,
        removed_senseclaims: removed_senseclaims,
        changed_senseclaims: changed_senseclaims,
        added_sense_references: added_sense_references,
        removed_sense_references: removed_sense_references,
        changed_sense_references: changed_sense_references,
        added_sense_qualifiers: added_sense_qualifiers,
        removed_sense_qualifiers: removed_sense_qualifiers,
        changed_sense_qualifiers: changed_sense_qualifiers
      }
    end

    current_content_senses = current_content['senses'] || []
    parent_content_senses  = parent_content['senses']  || []

    if parent_content.nil?
      current_content_senses.each_with_index do |current_sense, index|
        added_senses << { index: index }
        glosses = GlossAnalyzer.isolate_gloss_differences(current_sense, nil)
        added_glosses   += glosses[:added]
        removed_glosses += glosses[:removed]
        changed_glosses += glosses[:changed]
        senseclaims = InsideClaimAnalyzer.isolate_inside_claim_differences(current_sense, nil)
        added_senseclaims        += senseclaims[:added]
        removed_senseclaims      += senseclaims[:removed]
        changed_senseclaims      += senseclaims[:changed]
        added_sense_references   += senseclaims[:added_references]
        removed_sense_references += senseclaims[:removed_references]
        changed_sense_references += senseclaims[:changed_references]
        added_sense_qualifiers   += senseclaims[:added_qualifiers]
        removed_sense_qualifiers += senseclaims[:removed_qualifiers]
        changed_sense_qualifiers += senseclaims[:changed_qualifiers]
      end
    else
      current_content_senses.each_with_index do |current_sense, index|
        parent_sense = parent_content_senses[index]
        if parent_sense.nil?
          added_senses << { index: index }
          glosses = GlossAnalyzer.isolate_gloss_differences(current_sense, parent_sense)
          added_glosses   += glosses[:added]
          removed_glosses += glosses[:removed]
          changed_glosses += glosses[:changed]
          senseclaims = InsideClaimAnalyzer.isolate_inside_claim_differences(current_sense, nil)
          added_senseclaims        += senseclaims[:added]
          removed_senseclaims      += senseclaims[:removed]
          changed_senseclaims      += senseclaims[:changed]
          added_sense_references   += senseclaims[:added_references]
          removed_sense_references += senseclaims[:removed_references]
          changed_sense_references += senseclaims[:changed_references]
          added_sense_qualifiers   += senseclaims[:added_qualifiers]
          removed_sense_qualifiers += senseclaims[:removed_qualifiers]
          changed_sense_qualifiers += senseclaims[:changed_qualifiers]
        elsif current_sense != parent_sense
          changed_senses << { index: index }
          glosses = GlossAnalyzer.isolate_gloss_differences(current_sense, parent_sense)
          added_glosses   += glosses[:added]
          removed_glosses += glosses[:removed]
          changed_glosses += glosses[:changed]
          senseclaims = InsideClaimAnalyzer.isolate_inside_claim_differences(current_sense, parent_sense)
          added_senseclaims        += senseclaims[:added]
          removed_senseclaims      += senseclaims[:removed]
          changed_senseclaims      += senseclaims[:changed]
          added_sense_references   += senseclaims[:added_references]
          removed_sense_references += senseclaims[:removed_references]
          changed_sense_references += senseclaims[:changed_references]
          added_sense_qualifiers   += senseclaims[:added_qualifiers]
          removed_sense_qualifiers += senseclaims[:removed_qualifiers]
          changed_sense_qualifiers += senseclaims[:changed_qualifiers]
        end
      end
    end

    parent_content_senses.each_with_index do |parent_sense, index|
      current_sense = current_content_senses[index]
      next unless current_sense.nil?

      removed_senses << { index: index }
      glosses = GlossAnalyzer.isolate_gloss_differences(nil, parent_sense)
      added_glosses   += glosses[:added]
      removed_glosses += glosses[:removed]
      changed_glosses += glosses[:changed]
      senseclaims = InsideClaimAnalyzer.isolate_inside_claim_differences(nil, parent_sense)
      added_senseclaims        += senseclaims[:added]
      removed_senseclaims      += senseclaims[:removed]
      changed_senseclaims      += senseclaims[:changed]
      added_sense_references   += senseclaims[:added_references]
      removed_sense_references += senseclaims[:removed_references]
      changed_sense_references += senseclaims[:changed_references]
      added_sense_qualifiers   += senseclaims[:added_qualifiers]
      removed_sense_qualifiers += senseclaims[:removed_qualifiers]
      changed_sense_qualifiers += senseclaims[:changed_qualifiers]
    end

    {
      added_senses: added_senses,
      removed_senses: removed_senses,
      changed_senses: changed_senses,
      added_glosses: added_glosses,
      removed_glosses: removed_glosses,
      changed_glosses: changed_glosses,
      added_senseclaims: added_senseclaims,
      removed_senseclaims: removed_senseclaims,
      changed_senseclaims: changed_senseclaims,
      added_sense_references: added_sense_references,
      removed_sense_references: removed_sense_references,
      changed_sense_references: changed_sense_references,
      added_sense_qualifiers: added_sense_qualifiers,
      removed_sense_qualifiers: removed_sense_qualifiers,
      changed_sense_qualifiers: changed_sense_qualifiers
    }
  end
end
