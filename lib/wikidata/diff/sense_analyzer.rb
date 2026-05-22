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
    totals = empty_senseclaim_totals

    current_content_senses = current_content['senses'] if current_content
    parent_content_senses  = parent_content['senses']  if parent_content

    unless current_content_senses.is_a?(Array) && parent_content_senses.is_a?(Array)
      return { added_senses: added_senses, removed_senses: removed_senses, changed_senses: changed_senses,
               added_glosses: added_glosses, removed_glosses: removed_glosses,
               changed_glosses: changed_glosses }.merge(totals)
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
        accumulate_senseclaims(totals, current_sense, nil)
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
          accumulate_senseclaims(totals, current_sense, nil)
        elsif current_sense != parent_sense
          changed_senses << { index: index }
          glosses = GlossAnalyzer.isolate_gloss_differences(current_sense, parent_sense)
          added_glosses   += glosses[:added]
          removed_glosses += glosses[:removed]
          changed_glosses += glosses[:changed]
          accumulate_senseclaims(totals, current_sense, parent_sense)
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
      accumulate_senseclaims(totals, nil, parent_sense)
    end

    { added_senses: added_senses, removed_senses: removed_senses, changed_senses: changed_senses,
      added_glosses: added_glosses, removed_glosses: removed_glosses,
      changed_glosses: changed_glosses }.merge(totals)
  end

  def self.empty_senseclaim_totals
    {
      added_senseclaims: [], removed_senseclaims: [], changed_senseclaims: [],
      added_sense_references: [], removed_sense_references: [], changed_sense_references: [],
      added_sense_qualifiers: [], removed_sense_qualifiers: [], changed_sense_qualifiers: []
    }
  end

  private_class_method :empty_senseclaim_totals

  def self.accumulate_senseclaims(totals, current_sense, parent_sense)
    sc = InsideClaimAnalyzer.isolate_inside_claim_differences(current_sense, parent_sense)
    totals[:added_senseclaims]        += sc[:added]
    totals[:removed_senseclaims]      += sc[:removed]
    totals[:changed_senseclaims]      += sc[:changed]
    totals[:added_sense_references]   += sc[:added_references]
    totals[:removed_sense_references] += sc[:removed_references]
    totals[:changed_sense_references] += sc[:changed_references]
    totals[:added_sense_qualifiers]   += sc[:added_qualifiers]
    totals[:removed_sense_qualifiers] += sc[:removed_qualifiers]
    totals[:changed_sense_qualifiers] += sc[:changed_qualifiers]
  end
  private_class_method :accumulate_senseclaims
end
