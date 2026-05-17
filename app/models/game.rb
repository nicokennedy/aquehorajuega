class Game < ApplicationRecord
  belongs_to :home_team, class_name: "Team"
  belongs_to :away_team, class_name: "Team"
  belongs_to :competition, optional: true


  def live?
    status == "live"
  end

  def finished?
    status == "finished"
  end

  def upcoming?
    status == "scheduled"
  end

  def score_text
    return "#{home_score} - #{away_score}" if live? || finished?
    "vs"
  end

  def venue_time_zone
		case city
		when "Mexico City", "Guadalajara", "Monterrey", "Dallas", "Houston", "Kansas City"
			"Central Time (US & Canada)"
		when "Los Angeles", "San Francisco Bay Area", "Seattle", "Vancouver"
			"Pacific Time (US & Canada)"
		when "Toronto", "Boston", "New York/New Jersey", "Philadelphia", "Atlanta", "Miami"
			"Eastern Time (US & Canada)"
		else
			"Eastern Time (US & Canada)"
		end
	end

  before_validation :set_slug, on: [:create, :update]

  validates :slug, presence: true, uniqueness: true
  validates :external_id, uniqueness: true, allow_nil: true

  def to_param
    slug
  end

  private

  def set_slug
    return if slug.present?

    date = starts_at&.strftime("%Y-%m-%d")
    self.slug = [
      home_team&.name,
      "vs",
      away_team&.name,
      date
    ].compact.join(" ").parameterize
  end
end