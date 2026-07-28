class Competition < ApplicationRecord
  CANONICAL_SLUGS = {
    "conmebol-libertadores" => "libertadores",
    "conmebol-sudamericana" => "sudamericana",
    "fifa-world-cup" => "world-cup-2026",
    "uefa-champions-league" => "champions-league"
  }.freeze

  INDEXABLE_SLUGS = %w[
    world-cup-2026
    libertadores
    sudamericana
    liga-profesional
    copa-argentina
    champions-league
  ].freeze

  has_many :games, dependent: :destroy

  def self.canonical_slug(slug)
    CANONICAL_SLUGS.fetch(slug.to_s, slug.to_s)
  end

  def self.legacy_slug?(slug)
    CANONICAL_SLUGS.key?(slug.to_s)
  end

  def indexable?(now: Time.current)
    self.class::INDEXABLE_SLUGS.include?(slug) &&
      games.where("starts_at >= ?", 30.days.ago(now)).exists?
  end
end
