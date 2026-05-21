require "open-uri"
require "nokogiri"
require "json"

module Promiedos
  class Scraper
    API_BASE_URL = "https://api.promiedos.com.ar"

    LEAGUES = [
      {
        url: "https://www.promiedos.com.ar/league/liga-profesional/hc",
        id: "hc"
      },
      {
        url: "https://www.promiedos.com.ar/league/libertadores/bac",
        id: "bac"
      },
      {
        url: "https://www.promiedos.com.ar/league/conmebol-sudamericana/dij",
        id: "dij"
      },
      {
        url: "https://www.promiedos.com.ar/league/fifa-world-cup/fjda",
        id: "fjda"
      }
    ]

    def call
      LEAGUES.flat_map do |league_config|
        scrape_league(league_config)
      rescue => e
        Rails.logger.error("Promiedos::Scraper error for #{league_config[:url]}: #{e.message}")
        []
      end
    end

    private

    def scrape_league(league_config)
      html = URI.open(league_config[:url]).read
      doc = Nokogiri::HTML(html)

      next_data = doc.at_css("#__NEXT_DATA__")
      return [] unless next_data

      json = JSON.parse(next_data.text)
      data = json.dig("props", "pageProps", "data")
      return [] unless data

      league = data["league"]
      filters = data.dig("games", "filters") || []

      games = filters.flat_map do |filter|
        fetch_games_for_filter(league_config[:id], filter["key"])
      end.uniq { |game| game["id"] }

      [{
        "name" => league["name"],
        "url_name" => league["url_name"],
        "games" => games
      }]
    end

    def fetch_games_for_filter(league_id, filter_key)
      return [] if filter_key.blank?
      return [] if filter_key == "latest"

      url = "#{API_BASE_URL}/league/games/#{league_id}/#{filter_key}"

      json = JSON.parse(
        URI.open(url, "X-VER" => "1.11.7.3").read
      )

      json["games"] || []
    rescue => e
      Rails.logger.error("Promiedos::Scraper filter error #{league_id}/#{filter_key}: #{e.message}")
      []
    end
  end
end