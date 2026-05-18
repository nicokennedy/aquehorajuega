# app/services/promiedos/group_scraper.rb
require "open-uri"
require "nokogiri"
require "json"

module Promiedos
  class GroupScraper
    URLS = {
      "world-cup-2026" => "https://www.promiedos.com.ar/league/fifa-world-cup/fjda",
      "libertadores" => "https://www.promiedos.com.ar/league/libertadores/bac",
      "sudamericana" => "https://www.promiedos.com.ar/league/conmebol-sudamericana/dij",
      "champions-league" => "https://www.promiedos.com.ar/league/uefa-champions-league/fhc"
    }

    def call(slug)
      url = URLS[slug]
      return [] unless url

      html = URI.open(url).read
      doc = Nokogiri::HTML(html)

      next_data = doc.at_css("#__NEXT_DATA__")
      return [] unless next_data

      json = JSON.parse(next_data.text)

      json.dig("props", "pageProps", "data", "tables_groups") || []
    rescue OpenURI::HTTPError
      []
    rescue JSON::ParserError
      []
    end
  end
end