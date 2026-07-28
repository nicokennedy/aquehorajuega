module Calendar
  class IcsBuilder
    def self.for_game(game)
      new([game], name: "#{game.home_team.name} vs #{game.away_team.name}").call
    end

    def self.for_team(team, games)
      new(games, name: "Próximos partidos de #{team.name}").call
    end

    def initialize(games, name:)
      @games = games
      @name = name
    end

    def call
      lines = [
        "BEGIN:VCALENDAR",
        "VERSION:2.0",
        "PRODID:-//A Que Hora Juega//Calendario de partidos//ES",
        "CALSCALE:GREGORIAN",
        "METHOD:PUBLISH",
        "X-WR-CALNAME:#{escape(@name)}"
      ]
      @games.each { |game| lines.concat(event_lines(game)) }
      lines << "END:VCALENDAR"
      lines.join("\r\n") + "\r\n"
    end

    private

    def event_lines(game)
      summary = "#{game.home_team.name} vs #{game.away_team.name}"
      details = [game.competition&.name, game.stage].compact.join(" · ")
      location = [game.stadium, game.city].compact_blank.join(", ")

      [
        "BEGIN:VEVENT",
        "UID:#{escape(game.slug)}@#{Site::HOST}",
        "DTSTAMP:#{timestamp(game.updated_at || Time.current)}",
        "DTSTART:#{timestamp(game.starts_at)}",
        "SUMMARY:#{escape(summary)}",
        ("DESCRIPTION:#{escape(details)}" if details.present?),
        ("LOCATION:#{escape(location)}" if location.present?),
        "URL:#{Site::URL}/es/games/#{game.slug}",
        "END:VEVENT"
      ].compact
    end

    def timestamp(value)
      value.utc.strftime("%Y%m%dT%H%M%SZ")
    end

    def escape(value)
      value.to_s
        .gsub("\\", "\\\\")
        .gsub("\n", "\\n")
        .gsub(",", "\\,")
        .gsub(";", "\\;")
    end
  end
end
