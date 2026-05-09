class AddColorsToTeams < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :primary_color, :string
    add_column :teams, :secondary_color, :string
  end
end
