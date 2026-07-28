class Game < ApplicationRecord
  RETENTION_WINDOW = 180.days
  UPCOMING_STATUSES = %w[scheduled postponed suspended].freeze
  FINAL_STATUSES = %w[finished cancelled].freeze

  belongs_to :home_team, class_name: "Team"
  belongs_to :away_team, class_name: "Team"
  belongs_to :competition, optional: true

  scope :chronological, -> { order(:starts_at) }
  scope :reverse_chronological, -> { order(starts_at: :desc) }
  scope :future, ->(now = Time.current) {
    where(status: UPCOMING_STATUSES).where("starts_at >= ?", now)
  }
  scope :finished_results, -> { where(status: "finished") }
  scope :recent_results, ->(now = Time.current) {
    finished_results.where(starts_at: RETENTION_WINDOW.ago(now)..now)
  }
  scope :for_team, ->(team) {
    where("home_team_id = :id OR away_team_id = :id", id: team.id)
  }

  def live?
    status == "live"
  end

  def finished?
    status == "finished"
  end

  def upcoming?
    UPCOMING_STATUSES.include?(status)
  end

  def postponed?
    status == "postponed"
  end

  def suspended?
    status == "suspended"
  end

  def cancelled?
    status == "cancelled"
  end

  def score_text
    return "#{home_score}-#{away_score}" if (live? || finished?) && home_score.present? && away_score.present?
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
    end
  end

  before_validation :set_slug, on: [:create, :update]

  validates :slug, presence: true, uniqueness: true
  validates :external_id, uniqueness: true, allow_nil: true

  def to_param
    slug
  end

  def future?(now = Time.current)
    starts_at.present? && starts_at >= now && !finished? && !cancelled?
  end

  def opponent_for(team)
    home_team == team ? away_team : home_team
  end

  def home_for?(team)
    home_team == team
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
