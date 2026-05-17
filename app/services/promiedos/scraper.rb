require "open-uri"
require "nokogiri"
require "json"

module Promiedos
  class Scraper
    URL = "https://www.promiedos.com.ar/"

    def call
      html = URI.open(URL).read
      doc = Nokogiri::HTML(html)

      next_data = doc.at_css("#__NEXT_DATA__")

      return [] unless next_data

      json = JSON.parse(next_data.text)

      json
        .dig("props", "pageProps", "data", "leagues") || []
    end
  end
end