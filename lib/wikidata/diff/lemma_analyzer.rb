# frozen_string_literal: true

class LemmaAnalyzer
  def self.isolate_lemmas_differences(current_content, parent_content)
    if current_content.nil? && parent_content.nil?
      return {
        changed_lemmas: [],
        removed_lemmas: [],
        added_lemmas: []
      }
    end

    if current_content
      current_labels = current_content['lemmas']
      current_labels = {} if current_labels.nil? || current_labels.is_a?(Array)
    else
      current_labels = {}
    end
    if parent_content
      parent_labels = parent_content['lemmas']
      parent_labels = {} if parent_labels.nil? || parent_labels.is_a?(Array)
    else
      parent_labels = {}
    end

    changed_labels = []
    removed_labels = []
    added_labels = []

    # if parentid is 0, then add all labels as added and return it
    if parent_content.nil?
      current_labels.each_key do |lang|
        added_labels << { lang: lang }
      end
      return {
        changed_lemmas: changed_labels,
        removed_lemmas: removed_labels,
        added_lemmas: added_labels
      }
    else

      # Iterate over each language in the current labels
      (current_labels || {}).each do |lang, current_label|
        parent_label = parent_labels[lang]

        if parent_label.nil?
          added_labels << { lang: lang }
        elsif current_label != parent_label
          changed_labels << { lang: lang }
        end
      end

      # Iterate over each language in the parent labels to find removed labels
      (parent_labels || {}).each_key do |lang|
        removed_labels << { lang: lang } if current_labels[lang].nil?
      end
    end

    {
      changed_lemmas: changed_labels,
      removed_lemmas: removed_labels,
      added_lemmas: added_labels
    }
  end
end
