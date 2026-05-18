class AddPromiedosIdToTeams < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :promiedos_id, :string
  end
end
