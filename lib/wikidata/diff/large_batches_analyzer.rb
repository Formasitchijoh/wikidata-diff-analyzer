# frozen_string_literal: true

require_relative 'api'

class LargeBatchesAnalyzer
  # returns revision contents and parent contents for whole revision_ids array
  def self.handle_large_batches(revision_ids, batch_size)
    revision_contents = {}
    parent_contents = {}
    first_revisions = []

    revision_ids.each_slice(batch_size) do |batch|
      parent_ids = []
      parsed_contents = Api.get_revision_contents(batch)
      next unless parsed_contents

      # I have to check if any of the revision ids in the parsed content has parentid == 0
      parsed_contents.each do |revid, data|
        if data[:parentid].zero?
          first_revisions << revid
        else
          parent_ids << data[:parentid]
        end
      end
      revision_contents.merge!(parsed_contents)
      parent_contents_batch = Api.get_revision_contents(parent_ids)
      parent_contents.merge!(parent_contents_batch) if parent_contents_batch
    end

    build_result(revision_contents, parent_contents, first_revisions)
  end

  def self.build_result(revision_contents, parent_contents, first_revisions)
    result = {}
    revision_contents.each do |revid, data|
      parent_content = parent_contents[data[:parentid]]
      result[revid] = {
        current_content: data&.fetch(:content, nil),
        parent_content: parent_content&.fetch(:content, nil),
        comment: data&.fetch(:comment, nil),
        model: data&.fetch(:model, nil)
      }
    end
    first_revisions.each do |revid|
      result[revid] = {
        current_content: revision_contents[revid]&.fetch(:content, nil),
        parent_content: nil,
        comment: revision_contents[revid]&.fetch(:comment, nil),
        model: revision_contents[revid]&.fetch(:model, nil)
      }
    end
    result
  end
end
