module Promiedos
  class SyncGames
    def call
			Game.where("starts_at < ?", 7.days.ago).delete_all
      leagues = Promiedos::Scraper.new.call

      leagues.each do |league|
        competition = Competition.find_or_create_by!(
          name: league["name"]
        ) do |c|
          c.slug = league["url_name"]
        end

        league["games"].each do |game_data|
          sync_game(game_data, competition)
        end
      end
    end

    private

    def sync_game(data, competition)
        home_team = Team.find_or_create_by!(
            name: data["teams"][0]["name"]
        )

        away_team = Team.find_or_create_by!(
            name: data["teams"][1]["name"]
        )

        starts_at = parse_datetime(data["start_time"])

        game = Game.find_or_initialize_by(
					external_id: data["id"]
				)

				if game.new_record?
					existing_game = Game.find_by(
						slug: build_slug(
							home_team.name,
							away_team.name,
							starts_at
						)
					)

					game = existing_game if existing_game.present?
				end
        scores = data["scores"] || []

        game.assign_attributes(
						external_id: data["id"],
            home_team: home_team,
            away_team: away_team,
            competition: competition,
            starts_at: starts_at,
            status: map_status(data.dig("status", "enum")),
            home_score: scores[0],
            away_score: scores[1],
            minute: data["game_time"],
            stage: data["stage_round_name"]
        )

        game.save!
        end

    def parse_datetime(value)
			parsed = DateTime.strptime(value, "%d-%m-%Y %H:%M")

			Time.new(
				parsed.year,
				parsed.month,
				parsed.day,
				parsed.hour,
				parsed.minute,
				0,
				"-03:00"
			)
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