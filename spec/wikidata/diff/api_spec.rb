# frozen_string_literal: true

# spec/wikidata/diff/api_spec.rb

require './lib/wikidata/diff/api'
require 'rspec'

RSpec.describe Api do
  let(:revision_ids) do
    [
      2266123021, 2266341034, 2266123060, 2266123123, 2266123148,
      2266123175, 2266123210, 2266123270, 2266123325, 2266123373,
      2266123418, 2266341148, 2266123442, 2266123459, 2266123479,
      2266123502, 2266123529, 2266123536, 2266123548, 2266123562,
      2266123568, 2266341782, 2266123581, 2266123596, 2266123602
    ]
  end

  describe '.mediawiki_request' do
    it 'returns a truncation warning since query exceeds response size limit' do
      client = Api.api_client
      query = Api.get_query_parameters(revision_ids)
      
      response = Api.mediawiki_request(client, 'query', query)

      expect(response['warnings']).not_to be_nil
      expect(response['warnings']['result']['*']).to include(
        "This result was truncated because it would otherwise be larger than the limit of 12,582,912 bytes."
      )
    end
  end

  describe '.get_revision_contents' do
    it 'returns the correct result and handles the warning' do
      result = Api.get_revision_contents(revision_ids)

      expect { result }.not_to raise_error
      expect(result).to be_a(Hash)
      expect(result.size).to eq(25)
    end
  end

  describe '.retry_after_seconds' do
    def http_error_with_response(headers)
      response = instance_double('Faraday::Response', status: 429, headers: headers)
      err = MediawikiApi::HttpError.allocate
      err.instance_variable_set(:@response, response)
      err.instance_variable_set(:@status, 429)
      err.define_singleton_method(:response) { response }
      err.define_singleton_method(:status) { 429 }
      err
    end

    it 'returns the integer seconds when Retry-After is a number' do
      err = http_error_with_response('Retry-After' => '12')
      expect(Api.retry_after_seconds(err)).to eq(12)
    end

    it 'returns nil when the Retry-After header is absent' do
      err = http_error_with_response({})
      expect(Api.retry_after_seconds(err)).to be_nil
    end

    it 'returns nil when the Retry-After header is unparseable (e.g. HTTP-date)' do
      err = http_error_with_response('Retry-After' => 'Wed, 21 Oct 2026 07:28:00 GMT')
      expect(Api.retry_after_seconds(err)).to be_nil
    end

    it 'returns nil when the error has no response accessor (older gem versions)' do
      err = MediawikiApi::HttpError.new(429)
      expect(Api.retry_after_seconds(err)).to be_nil
    end

    it 'returns nil when error.response is nil' do
      err = MediawikiApi::HttpError.allocate
      err.instance_variable_set(:@status, 429)
      err.define_singleton_method(:response) { nil }
      expect(Api.retry_after_seconds(err)).to be_nil
    end
  end

  describe '.retry_delay_for' do
    def http_error_with_retry_after(value)
      response = instance_double('Faraday::Response',
                                 status: 429, headers: { 'Retry-After' => value })
      err = MediawikiApi::HttpError.allocate
      err.define_singleton_method(:response) { response }
      err.define_singleton_method(:status) { 429 }
      err
    end

    it 'returns the requested seconds for a normal value' do
      expect(Api.retry_delay_for(http_error_with_retry_after('12'))).to eq(12)
    end

    it 'falls back to the 5s default when the header is missing' do
      err = MediawikiApi::HttpError.new(429)
      expect(Api.retry_delay_for(err)).to eq(5)
    end

    it 'caps absurdly large values at 60s' do
      expect(Api.retry_delay_for(http_error_with_retry_after('3600'))).to eq(60)
    end
  end

  describe '.mediawiki_request 429 backoff' do
    it 'sleeps the requested Retry-After value before retrying' do
      response = instance_double('Faraday::Response',
                                 status: 429, headers: { 'Retry-After' => '7' })
      err = MediawikiApi::HttpError.allocate
      err.define_singleton_method(:response) { response }
      err.define_singleton_method(:status) { 429 }

      client = instance_double('MediawikiApi::Client')
      allow(client).to receive(:send).and_raise(err)
      allow(Api).to receive(:sleep)

      expect { Api.mediawiki_request(client, 'query', {}) }.to raise_error(MediawikiApi::HttpError)
      expect(Api).to have_received(:sleep).with(7).at_least(:once)
    end

    it 'falls back to a 5s sleep when no Retry-After header is sent' do
      err = MediawikiApi::HttpError.new(429)
      client = instance_double('MediawikiApi::Client')
      allow(client).to receive(:send).and_raise(err)
      allow(Api).to receive(:sleep)

      expect { Api.mediawiki_request(client, 'query', {}) }.to raise_error(MediawikiApi::HttpError)
      expect(Api).to have_received(:sleep).with(5).at_least(:once)
    end
  end
end
