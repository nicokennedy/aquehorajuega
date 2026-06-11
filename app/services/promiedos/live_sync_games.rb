module Promiedos
  class LiveSyncGames < SyncGames
    def call
      live_games = Game.where(status: "live").includes(:competition)
      return if live_games.empty?

      scraper = Promiedos::Scraper.new

      live_games.group_by(&:competition).each do |competition, games|
        league_id = competition.promiedos_id
        next unless league_id

        filter_keys = games.map(&:filter_key).compact.uniq
        filter_keys = competition.filter_keys.presence || filter_keys

        filter_keys.each do |filter_key|
          games_data = scraper.send(:fetch_games_for_filter, league_id, filter_key)
          live_external_ids = games.map(&:external_id).to_set

          games_data.select { |g| live_external_ids.include?(g["id"]) }.each do |game_data|
            game = Game.find_by(external_id: game_data["id"])
            next unless game

            scores = game_data["scores"] || []
            game.update!(
              status: map_status(game_data.dig("status", "enum")),
              home_score: scores[0],
              away_score: scores[1],
              minute: game_data["game_time"]
            )
          end
        rescue => e
          Rails.logger.error("Promiedos::LiveSyncGames error #{league_id}/#{filter_key}: #{e.message}")
        end
      end
    end
  end
end
