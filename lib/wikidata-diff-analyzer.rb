# frozen_string_literal: true

require_relative 'wikidata-diff-analyzer/version'
require_relative 'wikidata/diff/api'
require_relative 'wikidata/diff/large_batches_analyzer'
require_relative 'wikidata/diff/revision_analyzer'
require_relative 'wikidata/diff/total'

module WikidataDiffAnalyzer
  class Error < StandardError; end

  BATCH_SIZE = 50

  TOTAL_KEYS = %i[
    claims_added claims_removed claims_changed
    references_added references_removed references_changed
    qualifiers_added qualifiers_removed qualifiers_changed
    aliases_added aliases_removed aliases_changed
    labels_added labels_removed labels_changed
    descriptions_added descriptions_removed descriptions_changed
    sitelinks_added sitelinks_removed sitelinks_changed
    lemmas_added lemmas_removed lemmas_changed
    forms_added forms_removed forms_changed
    representations_added representations_removed representations_changed
    formclaims_added formclaims_removed formclaims_changed
    senses_added senses_removed senses_changed
    glosses_added glosses_removed glosses_changed
    senseclaims_added senseclaims_removed senseclaims_changed
    merge_to merge_from redirect undo restore
    clear_item create_item create_property create_lexeme
  ].freeze

  # Sets the User-Agent string sent on every wikidata.org API request.
  # Wikimedia API policy expects a descriptive UA identifying the consumer.
  # Set this once at application boot, before any analyze call.
  def self.user_agent=(val)
    Api.user_agent = val
  end

  def self.user_agent
    Api.user_agent
  end

  # Analyzes a set of revision ids and returns the differences between them.
  #
  # Returns a hash:
  #   diffs_analyzed_count: Integer
  #   diffs_not_analyzed:   Array of rev_ids that couldn't be analyzed
  #                         (e.g. parentid=0 special case 0, wikitext revs,
  #                         deleted/suppressed content, missing rev IDs)
  #   diffs:                { rev_id => per-rev diff hash }
  #   total:                aggregated totals across all analyzed diffs
  #
  # Streams revision content through one batch (50 input revs) at a time,
  # discarding fetched content as soon as the diffs for that batch are
  # computed. Memory peak is bounded by one batch's content (~12 MB
  # observed for typical wikidata items), independent of input size.
  #
  # Within each batch, parents whose IDs are also in the batch's input
  # set are read from the just-fetched current set rather than re-fetched
  # — empirically captures ~94% of cross-batch parent-overlap savings on
  # bot-tier inputs while keeping the streaming property.
  def self.analyze(revision_ids)
    revision_ids = revision_ids.uniq
    diffs = {}
    diffs_analyzed = []
    diffs_not_analyzed = []
    total = TOTAL_KEYS.to_h { |k| [k, 0] }

    # 0 is a sentinel that can never be analyzed.
    if revision_ids.include?(0)
      diffs_not_analyzed << 0
      revision_ids -= [0]
    end

    revision_ids.each_slice(BATCH_SIZE) do |batch|
      analyze_batch(batch, diffs, diffs_analyzed, total)
    end

    diffs_not_analyzed += revision_ids - diffs_analyzed

    {
      diffs_analyzed_count: diffs_analyzed.size,
      diffs_not_analyzed: diffs_not_analyzed,
      diffs: diffs,
      total: total
    }
  end

  # Fetches one batch's worth of content (currents + non-overlapping parents),
  # computes diffs, accumulates totals, and lets the fetched content go
  # out of scope at method exit.
  def self.analyze_batch(batch, diffs, diffs_analyzed, total)
    parsed_currents = Api.get_revision_contents(batch) || {}
    parsed_parents = fetch_missing_parents(parsed_currents)

    batch.each do |rev_id|
      data = parsed_currents[rev_id]
      next unless data && data[:content]

      parent_id = data[:parentid]
      parent_content =
        if parent_id.nil? || parent_id.zero?
          nil
        else
          (parsed_currents[parent_id] || parsed_parents[parent_id])&.fetch(:content, nil)
        end
      diff = RevisionAnalyzer.analyze_diff(
        current_content: data[:content],
        parent_content: parent_content,
        comment: data[:comment],
        model: data[:model]
      )
      diffs[rev_id] = diff
      Total.accumulate_totals(diff, total)
      diffs_analyzed << rev_id
    end
  end
  private_class_method :analyze_batch

  # Within-batch dedupe: parents whose IDs are already in the batch's
  # current-rev set don't need a separate fetch — we already have them.
  def self.fetch_missing_parents(parsed_currents)
    parent_ids_to_fetch = []
    parsed_currents.each_value do |data|
      pid = data[:parentid]
      next if pid.nil? || pid.zero?
      next if parsed_currents.key?(pid)

      parent_ids_to_fetch << pid
    end
    parent_ids_to_fetch.uniq!
    return {} if parent_ids_to_fetch.empty?

    Api.get_revision_contents(parent_ids_to_fetch) || {}
  end
  private_class_method :fetch_missing_parents
end
