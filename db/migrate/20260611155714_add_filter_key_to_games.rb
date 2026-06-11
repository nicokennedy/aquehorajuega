class AddFilterKeyToGames < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :filter_key, :string
  end
end
