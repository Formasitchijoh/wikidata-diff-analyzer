# frozen_string_literal: true

class GlossAnalyzer
  def self.isolate_gloss_differences(current_content, parent_content)
    if current_content.nil? && parent_content.nil?
      return {
        changed: [],
        removed: [],
        added: []
      }
    end

    if current_content
      current_glosses = current_content['glosses']
      current_glosses = {} if current_glosses.nil? || current_glosses.is_a?(Array)
    else
      current_glosses = {}
    end

    if parent_content
      parent_glosses = parent_content['glosses']
      parent_glosses = {} if parent_glosses.nil? || parent_glosses.is_a?(Array)
    else
      parent_glosses = {}
    end

    changed = []
    removed = []
    added = []

    # if parentid is 0, then add all labels as added and return it
    if parent_content.nil?
      current_glosses.each_key do |lang|
        added << { lang: lang }
      end
      return {
        changed: changed,
        removed: removed,
        added: added
      }
    else

      # Iterate over each language in the current labels
      (current_glosses || {}).each do |lang, current_gloss|
        parent_gloss = parent_glosses[lang]

        if parent_gloss.nil?
          added << { lang: lang }
        elsif current_gloss != parent_gloss
          changed << { lang: lang }
        end
      end

      # Iterate over each language in the parent labels to find removed labels
      (parent_glosses || {}).each_key do |lang|
        removed << { lang: lang } if current_glosses[lang].nil?
      end
    end

    {
      changed: changed,
      removed: removed,
      added: added
    }
  end
end
