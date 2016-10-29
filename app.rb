require_relative './gif_cities'
require 'json'

class App

  class InvalidSlackToken < StandardError; end

  API = GifCities::API.new

  def call env
    params = Rack::Request.new(env).params
    slack_guard params['token']
    success API.fetch_random(params['text'])
  rescue GifCities::QueryRequired
    error 'A search term is required.'
  rescue GifCities::NoResults
    error 'No GIFs matched your search.'
  end

  private

  def error message
    json_response({
      response_type: 'ephemeral',
      text: message,
    })
  end

  def success gif_url
    json_response({
      response_type: 'in_channel',
      attachments: [{
        fallback: gif_url,
        image_url: gif_url
      }],
    })
  end

  def json_response hash
    ['200', {'Content-Type' => 'application/json'}, [hash.to_json]]
  end

  def slack_guard token
    raise InvalidSlackToken if token != ENV['SLACK_TOKEN']
  end

end
