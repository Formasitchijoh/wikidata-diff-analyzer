# frozen_string_literal: true

require_relative 'representation_analyzer'
require_relative 'inside_claim_analyzer'

class FormAnalyzer
  def self.isolate_forms_differences(current_content, parent_content)
    added_forms = []
    removed_forms = []
    changed_forms = []
    added_representations = []
    removed_representations = []
    changed_representations = []
    added_formclaims = []
    removed_formclaims = []
    changed_formclaims = []
    added_form_references = []
    removed_form_references = []
    changed_form_references = []
    added_form_qualifiers = []
    removed_form_qualifiers = []
    changed_form_qualifiers = []

    current_forms = current_content&.fetch('forms', []) || []
    parent_forms = parent_content&.fetch('forms', []) || []

    current_forms.each_with_index do |current_form, index|
      parent_form = parent_forms[index]

      if parent_form.nil?
        added_forms << { index: index }
      elsif current_form != parent_form
        changed_forms << { index: index }
      end

      representations = RepresentationAnalyzer.isolate_representation_differences(current_form, parent_form)
      added_representations   += representations[:added]
      removed_representations += representations[:removed]
      changed_representations += representations[:changed]

      formclaims = InsideClaimAnalyzer.isolate_inside_claim_differences(current_form, parent_form)
      added_formclaims        += formclaims[:added]
      removed_formclaims      += formclaims[:removed]
      changed_formclaims      += formclaims[:changed]
      added_form_references   += formclaims[:added_references]
      removed_form_references += formclaims[:removed_references]
      changed_form_references += formclaims[:changed_references]
      added_form_qualifiers   += formclaims[:added_qualifiers]
      removed_form_qualifiers += formclaims[:removed_qualifiers]
      changed_form_qualifiers += formclaims[:changed_qualifiers]
    end

    parent_forms.each_with_index do |parent_form, index|
      current_form = current_forms[index]
      next unless current_form.nil?

      removed_forms << { index: index }

      representations = RepresentationAnalyzer.isolate_representation_differences(nil, parent_form)
      removed_representations += representations[:removed]

      formclaims = InsideClaimAnalyzer.isolate_inside_claim_differences(nil, parent_form)
      removed_formclaims      += formclaims[:removed]
      removed_form_references += formclaims[:removed_references]
      removed_form_qualifiers += formclaims[:removed_qualifiers]
    end

    {
      added_forms: added_forms,
      removed_forms: removed_forms,
      changed_forms: changed_forms,
      added_representations: added_representations,
      removed_representations: removed_representations,
      changed_representations: changed_representations,
      added_formclaims: added_formclaims,
      removed_formclaims: removed_formclaims,
      changed_formclaims: changed_formclaims,
      added_form_references: added_form_references,
      removed_form_references: removed_form_references,
      changed_form_references: changed_form_references,
      added_form_qualifiers: added_form_qualifiers,
      removed_form_qualifiers: removed_form_qualifiers,
      changed_form_qualifiers: changed_form_qualifiers
    }
  end
end
