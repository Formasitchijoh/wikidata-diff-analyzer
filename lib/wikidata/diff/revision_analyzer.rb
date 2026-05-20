# frozen_string_literal: true

require_relative 'claim_analyzer'
require_relative 'alias_analyzer'
require_relative 'label_analyzer'
require_relative 'description_analyzer'
require_relative 'sitelink_analyzer'
require_relative 'comment_analyzer'
require_relative 'form_analyzer'
require_relative 'sense_analyzer'
require_relative 'lemma_analyzer'
require_relative 'language_analyzer'

class RevisionAnalyzer
  CLAIM_TYPES = %i[added_claims removed_claims changed_claims added_references removed_references
                   changed_references added_qualifiers removed_qualifiers changed_qualifiers].freeze
  ALIAS_TYPES = %i[added_aliases removed_aliases changed_aliases].freeze
  LABEL_TYPES = %i[added_labels removed_labels changed_labels].freeze
  DESCRIPTION_TYPES = %i[added_descriptions removed_descriptions changed_descriptions].freeze
  SITELINK_TYPES = %i[added_sitelinks removed_sitelinks changed_sitelinks].freeze
  COMMENT_TYPES = %i[merge_to merge_from redirect undo restore clear_item].freeze
  LEMMA_TYPES = %i[added_lemmas removed_lemmas changed_lemmas].freeze
  FORM_TYPES = %i[added_forms removed_forms changed_forms added_representations removed_representations
                  changed_representations added_formclaims removed_formclaims changed_formclaims
                  added_form_references removed_form_references changed_form_references
                  added_form_qualifiers removed_form_qualifiers changed_form_qualifiers].freeze
  SENSE_TYPES = %i[added_senses removed_senses changed_senses added_glosses removed_glosses changed_glosses
                   added_senseclaims removed_senseclaims changed_senseclaims
                   added_sense_references removed_sense_references changed_sense_references
                   added_sense_qualifiers removed_sense_qualifiers changed_sense_qualifiers].freeze
  NOT_IN_ITEM = %i[create_lexeme create_property added_lemmas removed_lemmas changed_lemmas added_forms
                   removed_forms changed_forms added_senses removed_senses changed_senses added_representations
                   removed_representations changed_representations added_glosses removed_glosses changed_glosses
                   added_formclaims removed_formclaims changed_formclaims added_senseclaims removed_senseclaims
                   changed_senseclaims added_language changed_language added_lexical_category changed_lexical_category
                   added_form_references removed_form_references changed_form_references
                   added_form_qualifiers removed_form_qualifiers changed_form_qualifiers
                   added_sense_references removed_sense_references changed_sense_references
                   added_sense_qualifiers removed_sense_qualifiers changed_sense_qualifiers].freeze
  NOT_IN_PROPERTY = %i[create_lexeme create_item added_sitelinks removed_sitelinks changed_sitelinks
                       added_lemmas removed_lemmas changed_lemmas added_forms removed_forms changed_forms
                       added_senses removed_senses changed_senses added_representations removed_representations
                       changed_representations added_glosses removed_glosses changed_glosses added_formclaims
                       removed_formclaims changed_formclaims added_senseclaims removed_senseclaims changed_senseclaims
                       added_language changed_language added_lexical_category changed_lexical_category
                       added_form_references removed_form_references changed_form_references
                       added_form_qualifiers removed_form_qualifiers changed_form_qualifiers
                       added_sense_references removed_sense_references changed_sense_references
                       added_sense_qualifiers removed_sense_qualifiers changed_sense_qualifiers].freeze
  NOT_IN_LEXEME = %i[create_item create_property added_sitelinks changed_sitelinks removed_sitelinks
                     added_aliases changed_aliases removed_aliases added_labels changed_labels removed_labels added_descriptions changed_descriptions removed_descriptions].freeze
  LANGUAGE_TYPES = %i[added_language changed_language added_lexical_category changed_lexical_category].freeze

  # This method takes two revisions as input and returns the differences between them.
  def self.analyze_diff(revision_data)
    model = revision_data[:model]
    diff = {}
    case model
    when 'wikibase-item'
      item(diff, revision_data)
    when 'wikibase-property'
      property(diff, revision_data)
    when 'wikibase-lexeme'
      lexeme(diff, revision_data)
    end
    diff
  end

  def self.item(diff, revision_data)
    current_content = revision_data[:current_content]
    parent_content = revision_data[:parent_content]
    comment = revision_data[:comment]

    claim_diff = ClaimAnalyzer.isolate_claims_differences(current_content, parent_content)
    CLAIM_TYPES.each do |change_type|
      diff[change_type] = claim_diff[change_type].length
    end

    alias_diff = AliasAnalyzer.isolate_aliases_differences(current_content, parent_content)
    ALIAS_TYPES.each do |change_type|
      diff[change_type] = alias_diff[change_type].length
    end

    # Calculate label differences
    label_diff = LabelAnalyzer.isolate_labels_differences(current_content, parent_content)
    LABEL_TYPES.each do |change_type|
      diff[change_type] = label_diff[change_type].length
    end

    # Calculate description differences
    description_diff = DescriptionAnalyzer.isolate_descriptions_differences(current_content, parent_content)
    DESCRIPTION_TYPES.each do |change_type|
      diff[change_type] = description_diff[change_type].length
    end

    # Calculate sitelink differences
    sitelink_diff = SitelinkAnalyzer.isolate_sitelinks_differences(current_content, parent_content)
    SITELINK_TYPES.each do |change_type|
      diff[change_type] = sitelink_diff[change_type].length
    end

    phrases = CommentAnalyzer.isolate_comment_differences(comment)
    COMMENT_TYPES.each do |change_type|
      diff[change_type] = phrases[change_type]
    end
    diff.merge!(phrases.slice(:merge_target, :merge_source))

    NOT_IN_ITEM.each do |change_type|
      diff[change_type] = 0
    end

    diff[:create_item] = phrases[:create_item]

    diff
  end

  def self.property(diff, revision_data)
    current_content = revision_data[:current_content]
    parent_content = revision_data[:parent_content]
    comment = revision_data[:comment]

    claim_diff = ClaimAnalyzer.isolate_claims_differences(current_content, parent_content)
    CLAIM_TYPES.each do |change_type|
      diff[change_type] = claim_diff[change_type].length
    end

    alias_diff = AliasAnalyzer.isolate_aliases_differences(current_content, parent_content)
    ALIAS_TYPES.each do |change_type|
      diff[change_type] = alias_diff[change_type].length
    end

    # Calculate label differences
    label_diff = LabelAnalyzer.isolate_labels_differences(current_content, parent_content)

    LABEL_TYPES.each do |change_type|
      diff[change_type] = label_diff[change_type].length
    end

    # Calculate description differences
    description_diff = DescriptionAnalyzer.isolate_descriptions_differences(current_content, parent_content)
    DESCRIPTION_TYPES.each do |change_type|
      diff[change_type] = description_diff[change_type].length
    end

    phrases = CommentAnalyzer.isolate_comment_differences(comment)
    COMMENT_TYPES.each do |change_type|
      diff[change_type] = phrases[change_type]
    end

    diff[:create_property] = phrases[:create_item]

    NOT_IN_PROPERTY.each do |change_type|
      diff[change_type] = 0
    end
  end

  def self.lexeme(diff, revision_data)
    current_content = revision_data[:current_content]
    parent_content = revision_data[:parent_content]
    comment = revision_data[:comment]

    claim_diff = ClaimAnalyzer.isolate_claims_differences(current_content, parent_content)
    CLAIM_TYPES.each do |change_type|
      diff[change_type] = claim_diff[change_type].length
    end

    forms_diff = FormAnalyzer.isolate_forms_differences(current_content, parent_content)
    FORM_TYPES.each do |change_type|
      diff[change_type] = forms_diff[change_type].length
    end

    # Calculate label differences
    lemmas_diff = LemmaAnalyzer.isolate_lemmas_differences(current_content, parent_content)
    LEMMA_TYPES.each do |change_type|
      diff[change_type] = lemmas_diff[change_type].length
    end

    # Calculate description differences
    senses_diff = SenseAnalyzer.isolate_senses_differences(current_content, parent_content)
    SENSE_TYPES.each do |change_type|
      diff[change_type] = senses_diff[change_type].length
    end

    phrases = CommentAnalyzer.isolate_comment_differences(comment)
    COMMENT_TYPES.each do |change_type|
      diff[change_type] = phrases[change_type]
    end

    NOT_IN_LEXEME.each do |change_type|
      diff[change_type] = 0
    end
    language_diff = LanguageAnalyzer.isolate_language_differences(current_content, parent_content)
    LANGUAGE_TYPES.each do |change_type|
      diff[change_type] = language_diff[change_type].length
    end
    diff[:create_lexeme] = phrases[:create_item]
  end
end
