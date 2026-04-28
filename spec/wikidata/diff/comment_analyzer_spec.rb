# frozen_string_literal: true

require 'spec_helper'
require 'wikidata/diff/comment_analyzer'

RSpec.describe CommentAnalyzer do
  describe '.isolate_comment_differences' do
    it 'returns zeroed counters for nil and non-action comments' do
      expect(CommentAnalyzer.isolate_comment_differences(nil)[:merge_to]).to eq(0)
      expect(CommentAnalyzer.isolate_comment_differences('')[:merge_to]).to eq(0)
      expect(CommentAnalyzer.isolate_comment_differences('plain edit')[:merge_to]).to eq(0)
    end

    it 'extracts the merge target Q-id from a wbmergeitems-to comment' do
      result = CommentAnalyzer.isolate_comment_differences(
        '/* wbmergeitems-to:0||Q3350322 */'
      )
      expect(result[:merge_to]).to eq(1)
      expect(result[:merge_target]).to eq('Q3350322')
    end

    it 'extracts the merge source Q-id from a wbmergeitems-from comment' do
      result = CommentAnalyzer.isolate_comment_differences(
        '/* wbmergeitems-from:0||Q112434841 */'
      )
      expect(result[:merge_from]).to eq(1)
      expect(result[:merge_source]).to eq('Q112434841')
    end

    it 'still flags a merge even if the Q-id cannot be parsed' do
      result = CommentAnalyzer.isolate_comment_differences('wbmergeitems-to: weird format')
      expect(result[:merge_to]).to eq(1)
      expect(result[:merge_target]).to be_nil
    end
  end
end
