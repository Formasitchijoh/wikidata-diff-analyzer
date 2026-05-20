# frozen_string_literal: true

class LanguageAnalyzer
  def self.isolate_language_differences(current_content, parent_content)
    added_language = []
    changed_language = []
    added_lexical_category = []
    changed_lexical_category = []

    current_language = current_content&.fetch('language', nil)
    parent_language = parent_content&.fetch('language', nil)
    current_category = current_content&.fetch('lexicalCategory', nil)
    parent_category = parent_content&.fetch('lexicalCategory', nil)

    if parent_language.nil? && current_language
      added_language << { id: current_language }
    elsif current_language && parent_language && current_language != parent_language
      changed_language << { id: current_language }
    end

    if parent_category.nil? && current_category
      added_lexical_category << { id: current_category }
    elsif current_category && parent_category && current_category != parent_category
      changed_lexical_category << { id: current_category }
    end

    {
      added_language: added_language,
      changed_language: changed_language,
      added_lexical_category: added_lexical_category,
      changed_lexical_category: changed_lexical_category
    }
  end
end
