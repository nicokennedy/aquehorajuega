class ConsolidateDuplicateCompetitions < ActiveRecord::Migration[7.1]
  SLUG_MAPPINGS = {
    "conmebol-libertadores" => "libertadores",
    "conmebol-sudamericana" => "sudamericana",
    "fifa-world-cup" => "world-cup-2026",
    "uefa-champions-league" => "champions-league"
  }.freeze

  def up
    SLUG_MAPPINGS.each do |legacy_slug, canonical_slug|
      legacy = competition_for(legacy_slug)
      next unless legacy

      canonical = competition_for(canonical_slug)

      if canonical
        execute <<~SQL.squish
          UPDATE games
          SET competition_id = #{connection.quote(canonical["id"])}
          WHERE competition_id = #{connection.quote(legacy["id"])}
        SQL
        execute <<~SQL.squish
          DELETE FROM competitions
          WHERE id = #{connection.quote(legacy["id"])}
        SQL
      else
        execute <<~SQL.squish
          UPDATE competitions
          SET slug = #{connection.quote(canonical_slug)}
          WHERE id = #{connection.quote(legacy["id"])}
        SQL
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
      "Los registros duplicados se consolidaron preservando sus partidos"
  end

  private

  def competition_for(slug)
    connection.select_one(<<~SQL.squish)
      SELECT id FROM competitions WHERE slug = #{connection.quote(slug)} LIMIT 1
    SQL
  end
end
