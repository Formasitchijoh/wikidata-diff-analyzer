# frozen_string_literal: true

class DescriptionAnalyzer
  def self.isolate_descriptions_differences(current_content, parent_content)
    if current_content.nil? && parent_content.nil?
      return {
        changed_descriptions: [],
        removed_descriptions: [],
        added_descriptions: []
      }
    end

    if current_content
      current_descriptions = current_content['descriptions']
      current_descriptions = {} if current_descriptions.nil? || current_descriptions.is_a?(Array)
    else
      current_descriptions = {}
    end

    if parent_content
      parent_descriptions = parent_content['descriptions']
      parent_descriptions = {} if parent_descriptions.nil? || parent_descriptions.is_a?(Array)
    else
      parent_descriptions = {}
    end

    changed_descriptions = []    # Initialize as an array
    removed_descriptions = []    # Initialize as an array
    added_descriptions = []      # Initialize as an array

    # if parentid is 0, add all current description as added and return it
    if parent_content.nil?
      unless current_descriptions.empty?
        current_descriptions.each_key do |lang|
          added_descriptions << { lang: lang }
        end
      end
      return {
        changed_descriptions: changed_descriptions,
        removed_descriptions: removed_descriptions,
        added_descriptions: added_descriptions
      }
    else
      # Iterate over each language in the current descriptions
      current_descriptions.each do |lang, current_description|
        # checking if the parent descriptions is empty
        if parent_descriptions.empty?
          added_descriptions << { lang: lang }
        elsif parent_descriptions[lang].nil?
          added_descriptions << { lang: lang }
        elsif current_description != parent_descriptions[lang]
          changed_descriptions << { lang: lang }
        end
      end

      # Iterate over each language in the parent descriptions to find removed descriptions
      parent_descriptions.each_key do |lang|
        removed_descriptions << { lang: lang } if current_descriptions.empty?
      end
    end
    {
      changed_descriptions: changed_descriptions,
      removed_descriptions: removed_descriptions,
      added_descriptions: added_descriptions
    }
  end
end
