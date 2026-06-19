module SchemaHelper
  def sports_event_schema(game)
    {
      "@context": "https://schema.org",
      "@type": "SportsEvent",
      name: "#{game.home_team.name} vs #{game.away_team.name}",
      startDate: game.starts_at.iso8601,
      eventStatus: case game.status
        when "live" then "https://schema.org/EventMovedOnline"
        when "finished" then "https://schema.org/EventStatusOffline"
        else "https://schema.org/EventScheduled"
        end,
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

  def breadcrumb_schema(items)
    list = items.each_with_index.map do |item, i|
      {
        "@type": "ListItem",
        position: i + 1,
        name: item[:name],
        item: item[:url]
      }
    end

    {
      "@context": "https://schema.org",
      "@type": "BreadcrumbList",
      itemListElement: list
    }.to_json.html_safe
  end

  def faq_schema_for_team(team, today_games: [], upcoming_games: [])
    tz = "America/Argentina/Buenos_Aires"

    today_answer = if today_games.any?
      hora = today_games.first.starts_at.in_time_zone(tz).strftime("%H:%M")
      "Sí, #{team.name} juega hoy a las #{hora}hs (hora Argentina)."
    else
      next_game = upcoming_games.first
      if next_game
        mes = I18n.t("date.month_names")[next_game.starts_at.in_time_zone(tz).month]
        fecha = "#{next_game.starts_at.in_time_zone(tz).day} de #{mes}"
        "#{team.name} no juega hoy. Su próximo partido es el #{fecha}."
      else
        "#{team.name} no tiene partidos programados por el momento."
      end
    end

    next_answer = if upcoming_games.any?
      g = upcoming_games.first
      rival = g.home_team == team ? g.away_team.name : g.home_team.name
      mes = I18n.t("date.month_names")[g.starts_at.in_time_zone(tz).month]
      hora = g.starts_at.in_time_zone(tz).strftime("%H:%M")
      fecha = "#{g.starts_at.in_time_zone(tz).day} de #{mes} a las #{hora}"
      "El próximo partido de #{team.name} es contra #{rival} el #{fecha}hs (hora Argentina)."
    else
      "No hay próximos partidos cargados para #{team.name}."
    end

    competitions = upcoming_games.map(&:competition).compact.uniq
    comp_answer = if competitions.any?
      "#{team.name} tiene partidos en #{competitions.map(&:name).to_sentence(locale: :es)}."
    else
      "Consultá el fixture completo de #{team.name} en esta página."
    end

    {
      "@context": "https://schema.org",
      "@type": "FAQPage",
      "mainEntity": [
        {
          "@type": "Question",
          "name": "¿A qué hora juega #{team.name} hoy?",
          "acceptedAnswer": { "@type": "Answer", "text": today_answer }
        },
        {
          "@type": "Question",
          "name": "¿Cuál es el próximo partido de #{team.name}?",
          "acceptedAnswer": { "@type": "Answer", "text": next_answer }
        },
        {
          "@type": "Question",
          "name": "¿En qué competencias juega #{team.name}?",
          "acceptedAnswer": { "@type": "Answer", "text": comp_answer }
        }
      ]
    }.to_json.html_safe
  end
end