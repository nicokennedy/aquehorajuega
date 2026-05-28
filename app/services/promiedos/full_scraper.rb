require "open-uri"
require "nokogiri"
require "json"

module Promiedos
  class FullScraper < Scraper
    LEAGUES = [
      { url: "https://www.promiedos.com.ar/league/liga-profesional/hc", id: "hc" },
      { url: "https://www.promiedos.com.ar/league/libertadores/bac", id: "bac" },
      { url: "https://www.promiedos.com.ar/league/conmebol-sudamericana/dij", id: "dij" },
      { url: "https://www.promiedos.com.ar/league/fifa-world-cup/fjda", id: "fjda" },

      { url: "https://www.promiedos.com.ar/league/uefa-champions-league/fhc", id: "fhc" },
      { url: "https://www.promiedos.com.ar/league/fifa-club-world-cup/fajg", id: "fajg" },
      { url: "https://www.promiedos.com.ar/league/premier-league/h", id: "h" },
      { url: "https://www.promiedos.com.ar/league/laliga/bb", id: "bb" },
      { url: "https://www.promiedos.com.ar/league/serie-a/bh", id: "bh" },
      { url: "https://www.promiedos.com.ar/league/bundesliga/cf", id: "cf" },
      { url: "https://www.promiedos.com.ar/league/ligue-1/df", id: "df" },
      { url: "https://www.promiedos.com.ar/league/brasileirao-serie-a/bbd", id: "bbd" },
      { url: "https://www.promiedos.com.ar/league/liga-mx/beb", id: "beb" },
      { url: "https://www.promiedos.com.ar/league/mls/bae", id: "bae" }
    ]

    def call
      LEAGUES.flat_map do |league_config|
        scrape_league(league_config)
      rescue => e
        Rails.logger.error("Promiedos::FullScraper error for #{league_config[:url]}: #{e.message}")
        []
      end
    end
  end
end