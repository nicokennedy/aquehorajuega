class SeoMetadata
  MONTHS = %w[
    enero febrero marzo abril mayo junio
    julio agosto septiembre octubre noviembre diciembre
  ].freeze

  attr_reader :title, :description, :h1

  def initialize(title:, description:, h1:)
    @title = title
    @description = description
    @h1 = h1
  end

  def self.for_team(team:, today_game:, next_game:)
    if today_game
      rival = today_game.opponent_for(team)&.name
      new(
        title: compact_title("¿A qué hora juega #{team.name} hoy? Horario y rival"),
        description: [
          "#{team.name} juega hoy",
          ("contra #{rival}" if rival),
          "a las #{time(today_game.starts_at)}",
          ("por #{today_game.competition.name}" if today_game.competition)
        ].compact.join(" ") + ". Consultá los detalles del partido.",
        h1: "¿A qué hora juega #{team.name} hoy?"
      )
    elsif next_game
      rival = next_game.opponent_for(team)&.name
      new(
        title: compact_title("Próximo partido de #{team.name}: fecha y horario"),
        description: [
          "Próximo partido de #{team.name}:",
          ("contra #{rival}" if rival),
          "el #{date(next_game.starts_at)}",
          "a las #{time(next_game.starts_at)}",
          ("por #{next_game.competition.name}" if next_game.competition)
        ].compact.join(" ") + ".",
        h1: "Próximo partido de #{team.name}"
      )
    else
      new(
        title: compact_title("#{team.name}: próximos partidos y resultados"),
        description: "Consultá cuándo juega #{team.name}, sus próximos partidos y últimos resultados confirmados.",
        h1: "Próximos partidos de #{team.name}"
      )
    end
  end

  def self.for_game(game:, tickets_available: false)
    match = "#{game.home_team.name} vs #{game.away_team.name}"
    competition = game.competition&.name

    if game.live?
      new(
        title: compact_title("#{match} en vivo: resultado y minuto"),
        description: "#{match} en vivo#{competition ? " por #{competition}" : ""}. Consultá resultado, minuto y detalles del partido.",
        h1: "#{match}: partido en vivo"
      )
    elsif game.finished?
      new(
        title: compact_title("#{match}: resultado final"),
        description: "#{match} terminó #{game.score_text}#{competition ? " por #{competition}" : ""}. Consultá el resultado y los detalles.",
        h1: "#{match}: resultado final"
      )
    else
      suffix = tickets_available ? "horario, fecha y entradas" : "horario, fecha y detalles"
      new(
        title: compact_title("#{match}: #{suffix}"),
        description: [
          "#{game.home_team.name} juega contra #{game.away_team.name}",
          "el #{date(game.starts_at)}",
          "a las #{time(game.starts_at)}",
          ("por #{competition}" if competition)
        ].compact.join(" ") + ". Consultá horario#{game.stadium.present? ? ", estadio" : ""}#{tickets_available ? " y opciones de entradas" : ""}.",
        h1: "#{match}: horario y detalles del partido"
      )
    end
  end

  def self.for_today(date)
    new(
      title: "Partidos de hoy: horarios y resultados en vivo",
      description: "Partidos de hoy #{date(date)}, ordenados por competición y horario. Consultá resultados en vivo y próximos encuentros.",
      h1: "Partidos de hoy"
    )
  end

  def self.for_competition(competition)
    new(
      title: compact_title("#{competition.name}: partidos, resultados y fixture"),
      description: "Partidos de hoy, próximos encuentros y últimos resultados de #{competition.name}.",
      h1: competition.name
    )
  end

  def self.date(value)
    local = value.in_time_zone("America/Argentina/Buenos_Aires")
    "#{local.day} de #{MONTHS[local.month - 1]} de #{local.year}"
  end

  def self.time(value)
    value.in_time_zone("America/Argentina/Buenos_Aires").strftime("%H:%M")
  end

  def self.compact_title(value)
    value.truncate(65, omission: "…")
  end

  private_class_method :compact_title
end
