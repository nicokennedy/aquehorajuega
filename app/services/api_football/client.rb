# app/services/api_football/client.rb
require "net/http"
require "json"

module ApiFootball
  class Client
    BASE_URL = "https://v3.football.api-sports.io"

    def self.get(path, params = {})
      uri = URI("#{BASE_URL}#{path}")
      uri.query = URI.encode_www_form(params) if params.any?

      request = Net::HTTP::Get.new(uri)
      request["x-apisports-key"] = ENV.fetch("API_FOOTBALL_KEY")

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      JSON.parse(response.body)
    end
  end
end