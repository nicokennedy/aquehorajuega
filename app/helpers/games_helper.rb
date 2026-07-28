module GamesHelper
  def game_status_label(game)
    return "En vivo#{game.minute.present? ? " · #{game.minute}'" : ""}" if game.live?
    return "Final" if game.finished?
    return "Suspendido" if game.suspended?
    return "Reprogramado" if game.postponed?
    return "Cancelado" if game.cancelled?

    "Programado"
  end

  def full_spanish_date(value)
    local = value.in_time_zone("America/Argentina/Buenos_Aires")
    "#{I18n.l(local.to_date, format: "%A")} #{local.day} de #{mes_en_español(local)} de #{local.year}"
  end

  def days_until_game(game)
    return unless game&.starts_at

    today = Time.current.in_time_zone("America/Argentina/Buenos_Aires").to_date
    date = game.starts_at.in_time_zone("America/Argentina/Buenos_Aires").to_date
    days = (date - today).to_i
    return "hoy" if days.zero?
    return "mañana" if days == 1
    return "en #{days} días" if days.positive?
  end
end
