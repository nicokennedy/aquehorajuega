module SchemaHelper
  def sports_event_schema(game)
    {
      "@context": "https://schema.org",
      "@type": "SportsEvent",
      name: "#{game.home_team.name} vs #{game.away_team.name}",
      startDate: game.starts_at.iso8601,
      eventStatus: "https://schema.org/EventScheduled",
      eventAttendanceMode: "https://schema.org/OfflineEventAttendanceMode",
      sport: "Soccer",
      location: {
        "@type": "Place",
        name: game.stadium.presence || game.city.presence || "Estadio por confirmar",
        address: {
          "@type": "PostalAddress",
          addressLocality: game.city.presence || "Ciudad por confirmar"
        }
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
      ],
      organizer: {
        "@type": "Organization",
        name: game.competition&.name
      },
      description: "Horario de #{game.home_team.name} vs #{game.away_team.name} en tu país."
    }.to_json.html_safe
  end

  def faq_schema_for_team(team)
    {
      "@context": "https://schema.org",
      "@type": "FAQPage",
      "mainEntity": [
        {
          "@type": "Question",
          "name": "¿A qué hora juega #{team.name} hoy?",
          "acceptedAnswer": {
            "@type": "Answer",
            "text": "Consultá los horarios actualizados de #{team.name} según tu país y zona horaria."
          }
        },
        {
          "@type": "Question",
          "name": "¿Dónde ver los partidos de #{team.name}?",
          "acceptedAnswer": {
            "@type": "Answer",
            "text": "Mostramos horarios locales, competencias y próximos partidos de #{team.name}."
          }
        },
        {
          "@type": "Question",
          "name": "¿Cuáles son los próximos partidos de #{team.name}?",
          "acceptedAnswer": {
            "@type": "Answer",
            "text": "Encontrá el fixture actualizado y los próximos encuentros de #{team.name}."
          }
        }
      ]
    }.to_json.html_safe
  end
end