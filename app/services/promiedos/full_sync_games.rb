module Promiedos
  class FullSyncGames < SyncGames
    private

    def scraper
      Promiedos::FullScraper.new
    end
  end
end