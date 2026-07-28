module Promiedos
  class SyncGames
    def call
      Game.where("starts_at < ?", Game::RETENTION_WINDOW.ago).delete_all
      leagues = scraper.call
      processed_games = 0

      leagues.each do |league|
        competition_slug = Competition.canonical_slug(league["url_name"])
        competition_name = canonical_competition_name(league["name"], competition_slug)

        competition = Competition.find_or_create_by!(slug: competition_slug) do |c|
          c.name = competition_name
        end

        competition.update!(
          name: competition_name,
          promiedos_id: league["promiedos_id"],
          filter_keys: league["filter_keys"]
        )

        league["games"].each do |game_data|
          sync_game(game_data, competition)
          processed_games += 1
        end
      end

      Promiedos::GroupScraper.new.sync_team_ids!
      processed_games
    end

    def scraper
      Promiedos::Scraper.new
    end

    private

    def canonical_competition_name(name, slug)
      case slug
      when "world-cup-2026"
        "Mundial 2026"
      when "libertadores"
        "Libertadores"
      when "sudamericana"
        "Sudamericana"
      else
        name
      end
    end

    def sync_game(data, competition)
      home_data = data["teams"][0]
      away_data = data["teams"][1]

      home_team = Team.find_or_initialize_by(name: home_data["name"])
      home_team.promiedos_id = home_data["id"]
      home_team.save!

      away_team = Team.find_or_initialize_by(name: away_data["name"])
      away_team.promiedos_id = away_data["id"]
      away_team.save!

      starts_at = parse_datetime(data["start_time"])
      target_slug = build_slug(home_team.name, away_team.name, starts_at)

      game = Game.find_by(external_id: data["id"])
      game ||= Game.find_by(slug: target_slug)
      game ||= Game.new

      scores = data["scores"] || []

      game.assign_attributes(
        external_id: data["id"],
        home_team: home_team,
        away_team: away_team,
        competition: competition,
        starts_at: starts_at,
        slug: game.persisted? ? game.slug : target_slug,
        status: map_status(data.dig("status", "enum")),
        home_score: scores[0],
        away_score: scores[1],
        minute: data["game_time"],
        stage: data["stage_round_name"],
        filter_key: data["filter_key"]
      )

      game.save!
    end

    def parse_datetime(value)
      Time.find_zone!("America/Argentina/Buenos_Aires")
        .strptime(value, "%d-%m-%Y %H:%M")
    end

    def map_status(enum)
      case enum
      when 1
        "scheduled"
      when 2
        "live"
      when 3
        "finished"
      else
        "scheduled"
      end
    end

    def build_slug(home, away, starts_at)
      [
        home,
        "vs",
        away,
        starts_at.strftime("%Y-%m-%d")
      ].join(" ").parameterize
    end
  end
end
