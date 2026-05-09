class Team < ApplicationRecord
  has_many :home_games, class_name: "Game", foreign_key: "home_team_id"
  has_many :away_games, class_name: "Game", foreign_key: "away_team_id"

  def to_param
    name.parameterize
  end

  def games
    Game.where("home_team_id = :id OR away_team_id = :id", id: id)
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
end