module SchemaHelper
  # Zona horaria de referencia para todo el sitio (los horarios "oficiales" se
  # muestran en hora Argentina y luego se adaptan en el cliente).
  AR_TZ = "America/Argentina/Buenos_Aires".freeze

  # Meses en español. Usamos esta constante en lugar de strftime("%B") o
  # I18n.l(..., format: "%B") porque esos dependen del locale activo y del gem
  # rails-i18n (que NO está instalado): devolvían "June"/"July" o
  # "translation missing", destruyendo el SEO.
  MESES_ES = %w[
    enero febrero marzo abril mayo junio
    julio agosto septiembre octubre noviembre diciembre
  ].freeze

  # Helper seguro para obtener el nombre del mes en español.
  def mes_en_español(date, tz = AR_TZ)
    return nil if date.nil?

    MESES_ES[date.in_time_zone(tz).month - 1]
  end

  # "12 de marzo" — nunca devuelve meses en inglés ni translation missing.
  def fecha_en_español(date, tz = AR_TZ)
    return nil if date.nil?

    local = date.in_time_zone(tz)
    "#{local.day} de #{mes_en_español(local, tz)}"
  end

  # "21:30" en hora Argentina.
  def hora_argentina(date, tz = AR_TZ)
    return nil if date.nil?

    date.in_time_zone(tz).strftime("%H:%M")
  end

  # Nombre del rival de `team` en un partido dado. Devuelve nil si el partido
  # o el rival no están cargados (caso edge: partido sin rival).
  def rival_name_for(game, team)
    return nil if game.nil?

    rival = game.home_team == team ? game.away_team : game.home_team
    rival&.name.presence
  end

  def sports_event_schema(game)
    return "".html_safe if game.nil? || game.starts_at.nil?

    home = game.home_team&.name.presence || "Equipo local"
    away = game.away_team&.name.presence || "Equipo visitante"

    schema = {
      "@context": "https://schema.org",
      "@type": "SportsEvent",
      name: "#{home} vs #{away}",
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
        { "@type": "SportsTeam", name: home },
        { "@type": "SportsTeam", name: away }
      ],
      description: "Horario de #{home} vs #{away} en tu país."
    }

    # Solo incluimos organizer si la competencia está cargada: un name nil
    # generaría schema inválido.
    if game.competition&.name.present?
      schema[:organizer] = {
        "@type": "Organization",
        name: game.competition.name
      }
    end

    schema.to_json.html_safe
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
    tz = AR_TZ
    next_game = upcoming_games.first

    today_answer =
      if today_games.any?
        g = today_games.first
        rival = rival_name_for(g, team)
        hora = hora_argentina(g.starts_at, tz)
        base = "Sí, #{team.name} juega hoy a las #{hora}hs (hora Argentina)"
        rival ? "#{base} contra #{rival}." : "#{base}."
      elsif next_game
        fecha = fecha_en_español(next_game.starts_at, tz)
        "#{team.name} no juega hoy. Su próximo partido es el #{fecha}."
      else
        "#{team.name} no tiene partidos programados por el momento."
      end

    next_answer =
      if next_game
        rival = rival_name_for(next_game, team)
        fecha = fecha_en_español(next_game.starts_at, tz)
        hora = hora_argentina(next_game.starts_at, tz)
        rival_txt = rival ? " contra #{rival}" : ""
        "El próximo partido de #{team.name} es#{rival_txt} el #{fecha} a las #{hora}hs (hora Argentina)."
      else
        "No hay próximos partidos cargados para #{team.name}."
      end

    competitions = upcoming_games.map(&:competition).compact.uniq
    comp_answer =
      if competitions.any?
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
