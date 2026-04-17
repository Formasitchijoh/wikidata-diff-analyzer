# frozen_string_literal: true

require 'json'
require 'mediawiki_api'

class Api
  API_URL = 'https://www.wikidata.org/w/api.php'

  def self.get_revision_contents(revision_ids)
    revision_ids = revision_ids.uniq if revision_ids
    response = fetch_all_revisions(revision_ids)

    return {} if response.nil? || response['pages'].nil?

    parse_revisions(response['pages'])
  rescue MediawikiApi::ApiError => e
    puts "Error retrieving revision content: #{e.message}"
    {}
  rescue JSON::ParserError => e
    puts "Error parsing JSON content: #{e.message}"
    raise e
  end

  def self.get_query_parameters(revision_ids)
    {
      prop: 'revisions',
      revids: revision_ids&.join('|'),
      rvslots: 'main',
      rvprop: 'content|ids|comment',
      format: 'json'
    }
  end

  def self.fetch_all_revisions(revision_ids)
    query = get_query_parameters(revision_ids)
    client = api_client
    data = {}
    continue_param = nil

    loop do
      query.merge!(continue_param) if continue_param
      response = mediawiki_request(client, 'query', query)
      break unless response

      merge_page_data(data, response.data['pages'])

      continue_param = response['continue']
      break unless continue_param
    end

    data
  end

  def self.merge_page_data(data, pages)
    return unless pages

    pages.each do |pageid, page_data|
      if data['pages'] && data['pages'][pageid]
        existing_page_data = data['pages'][pageid]

        existing_page_data.merge!(page_data) do |key, old_val, new_val|
          key == 'revisions' && old_val.is_a?(Array) && new_val.is_a?(Array) ? old_val + new_val : new_val
        end
      else
        data['pages'] ||= {}
        data['pages'][pageid] = page_data
      end
    end
  end

  def self.mediawiki_request(client, action, query)
    tries ||= 3
    client.send(action, query)
  rescue StandardError => e
    tries -= 1
    sleep 1 if too_many_requests?(e)
    retry unless tries.zero?
    raise(e)
  end

  def self.api_client
    @api_client ||= MediawikiApi::Client.new(API_URL)
  end

  def self.too_many_requests?(error)
    error.is_a?(MediawikiApi::HttpError) && error.status == 429
  end

  def self.parse_revisions(pages)
    parsed_contents = {}

    pages.each_key do |page|
      revisions = pages[page]['revisions']

      revisions.each do |revision|
        parsed_content = parse_revision(revision)
        parsed_contents[revision['revid']] = parsed_content if parsed_content
      end
    end

    parsed_contents
  end

  def self.parse_revision(revision)
    content_model = revision['slots']['main']['contentmodel']

    return nil unless %w[wikibase-item wikibase-property wikibase-lexeme].include?(content_model)

    revid = revision['revid']
    parentid = revision['parentid']

    if revision.key?('texthidden')
      { content: nil, comment: nil, parentid: parentid, model: content_model }
    elsif revision.key?('commenthidden')
      content = revision['slots']['main']['*']
      { content: JSON.parse(content), comment: nil, parentid: parentid, model: content_model }
    else
      content = revision['slots']['main']['*']
      comment = revision['comment']

      if revid.nil? || revid.zero?
        { content: nil, comment: nil, parentid: nil, model: 'wikibase-item' }
      else
        { content: JSON.parse(content), comment: comment, parentid: parentid, model: content_model }
      end
    end
  end
end
