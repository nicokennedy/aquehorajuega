class Team < ApplicationRecord
  RECENT_RESULT_WINDOW = Game::RETENTION_WINDOW

  has_many :home_games, class_name: "Game", foreign_key: "home_team_id"
  has_many :away_games, class_name: "Game", foreign_key: "away_team_id"

  before_validation :set_slug

  # Busca un equipo por el slug de la URL. Primero por la columna slug
  # (poblada con parameterize, igual que to_param). Como fallback usa el
  # query viejo basado en el nombre, por si algún equipo todavía no tiene
  # slug. Antes esto daba 404 en equipos con acento/ñ porque el link decía
  # "paises-bajos" pero la búsqueda usaba REPLACE(name) -> "países-bajos".
  def self.find_by_slug!(param)
    key = param.to_s.downcase
    find_by(slug: key) || find_by!("LOWER(REPLACE(name, ' ', '-')) = ?", key)
  end

  def to_param
    slug.presence || name.to_s.parameterize
  end

  def games
    Game.for_team(self)
  end

  def indexable?(now: Time.current)
    games.where(status: Game::UPCOMING_STATUSES + ["live"]).where("starts_at >= ?", now).exists? ||
      games.where(status: "finished", starts_at: RECENT_RESULT_WINDOW.ago(now)..now).exists?
  end

  def seo_last_modified_at
    games.maximum(:updated_at) || updated_at
  end

  def national_team?
    flag.present?
  end

  def badge_style
    return "" if national_team?

    color1 = primary_color.presence || "#7ee7a8"
    color2 = secondary_color.presence || color1

    "background: linear-gradient(135deg, #{color1} 0 50%, #{color2} 50% 100%);"
  end

  private

  def set_slug
    self.slug = name.to_s.parameterize if slug.blank? && name.present?
  end
end
