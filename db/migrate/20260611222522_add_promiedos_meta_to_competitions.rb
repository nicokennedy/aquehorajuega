class AddPromiedosMetaToCompetitions < ActiveRecord::Migration[7.1]
  def change
    add_column :competitions, :promiedos_id, :string
    add_column :competitions, :filter_keys, :jsonb
  end
end
