# frozen_string_literal: true

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
    }.freeze

    def call(slug)
      data_for(slug).dig("tables_groups") || []
    rescue OpenURI::HTTPError, JSON::ParserError, NoMethodError
      []
    end

    def sync_team_ids!
      URLS.keys.each do |slug|
        data = data_for(slug)
        raw_games = data["games"]

        teams = []

        walker = lambda do |obj|
          case obj
          when Hash
            teams.concat(obj["teams"]) if obj["teams"].is_a?(Array)
            obj.values.each { |value| walker.call(value) }
          when Array
            obj.each { |value| walker.call(value) }
          end
        end

        walker.call(raw_games)

        teams.uniq { |team| team["id"] }.each do |team_data|
          Team.where("LOWER(name) = ?", team_data["name"].downcase)
              .update_all(promiedos_id: team_data["id"])
        end
      rescue OpenURI::HTTPError, JSON::ParserError, NoMethodError => e
        Rails.logger.error("Promiedos::GroupScraper sync error for #{slug}: #{e.message}")
      end
    end

    private

    def data_for(slug)
      url = URLS[slug]
      return {} unless url

      html = URI.open(url).read
      doc = Nokogiri::HTML(html)
      next_data = doc.at_css("#__NEXT_DATA__")
      return {} unless next_data

      json = JSON.parse(next_data.text)

      json.dig("props", "pageProps", "data") || {}
    end
  end
end