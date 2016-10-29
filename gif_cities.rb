require 'net/http'
require 'uri'
require 'json'

module GifCities

  class QueryRequired < StandardError; end
  class NoResults < StandardError; end

  class API

    REQUEST_URL = 'https://wbgrp-svc060.us.archive.org/api/v1/gifsearch'
    NO_RESULTS_GIF = '20090727153912/http://www.geocities.com/doiglahrnope/Penguins.gif'
    RESULT_PREFIX = 'https://web.archive.org/web/'

    def fetch_random text
      build_gif_url(request(text).sample)
    end

    private

    def request text
      query_guard text
      uri = URI(REQUEST_URL + '?' + URI.encode_www_form({ q: text }))
      results = JSON.parse(Net::HTTP.get_response(uri).body)
      no_results_guard results
      results
    end

    def query_guard text
      raise QueryRequired unless text && !text.empty?
    end

    def no_results_guard results
      raise NoResults if results[0]['gif'] == NO_RESULTS_GIF
    end

    def build_gif_url result
      RESULT_PREFIX + result['gif']
    end

  end
end
