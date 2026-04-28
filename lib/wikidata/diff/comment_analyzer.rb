# frozen_string_literal: true

class CommentAnalyzer
  def self.isolate_comment_differences(comment)
    phrases = {
      'merge_to': 0,
      'merge_from': 0,
      'redirect': 0,
      'undo': 0,
      'restore': 0,
      'clear_item': 0,
      'create_item': 0
    }

    return phrases if comment.nil?

    # Merge edit summaries embed the counterparty Q-id, e.g.
    # "/* wbmergeitems-to:0||Q3350322 */". Capture it so consumers can tell
    # which item was merged into which without re-fetching the comment.
    if (m = comment.match(/wbmergeitems-from:\d*\|\|(Q\d+)/))
      phrases[:merge_from] = 1
      phrases[:merge_source] = m[1]
    elsif comment.include?('wbmergeitems-from')
      phrases[:merge_from] = 1
    end

    if (m = comment.match(/wbmergeitems-to:\d*\|\|(Q\d+)/))
      phrases[:merge_to] = 1
      phrases[:merge_target] = m[1]
    elsif comment.include?('wbmergeitems-to')
      phrases[:merge_to] = 1
    end

    phrases[:redirect] = 1 if comment.include?('wbcreateredirect')

    phrases[:undo] = 1 if comment.include?('undo:')

    phrases[:restore] = 1 if comment.include?('restore:')

    phrases[:clear_item] = 1 if comment.include?('wbeditentity-override')

    # create-property, create-item, create-lexeme all includes this phrase
    # so based on content model in revision analyzer, it is decided which one it is
    phrases[:create_item] = 1 if comment.include?('wbeditentity-create')

    phrases
  end
end
