require_relative './gif_cities'
require 'json'

class App

  API = GifCities::API.new

  def call env
    search_text = Rack::Request.new(env).params['text']
    success API.fetch_random(search_text)
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
      text: gif_url,
      attachments: [{
        fallback: gif_url,
        image_url: gif_url
      }],
    })
  end

  def json_response hash
    ['200', {'Content-Type' => 'application/json'}, [hash.to_json]]
  end

end
