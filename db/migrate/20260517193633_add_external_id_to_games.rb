class AddExternalIdToGames < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :external_id, :string
    add_index :games, :external_id, unique: true
  end
end