class SynchronizationRun < ApplicationRecord
  KINDS = %w[sync sync_live full_sync].freeze
  STATUSES = %w[running succeeded failed skipped].freeze

  validates :kind, inclusion: { in: KINDS }
  validates :status, inclusion: { in: STATUSES }

  scope :successful, -> { where(status: "succeeded") }

  def self.last_successful_at(kind)
    successful.where(kind: kind).maximum(:finished_at)
  end
end
