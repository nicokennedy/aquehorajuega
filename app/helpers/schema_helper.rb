module SchemaHelper
  def sports_event_schema(game)
    {
      "@context": "https://schema.org",
      "@type": "SportsEvent",
      name: "#{game.home_team.name} vs #{game.away_team.name}",
      startDate: game.starts_at.iso8601,
      eventStatus: "https://schema.org/EventScheduled",
      sport: "Soccer",
      location: {
        "@type": "Place",
        name: game.stadium,
        address: game.city
      },
      competitor: [
        {
          "@type": "SportsTeam",
          name: game.home_team.name
        },
        {
          "@type": "SportsTeam",
          name: game.away_team.name
        }
      ]
    }.to_json.html_safe
  end
end