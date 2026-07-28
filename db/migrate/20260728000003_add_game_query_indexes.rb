class AddGameQueryIndexes < ActiveRecord::Migration[7.1]
  def change
    add_index :games, [:home_team_id, :starts_at],
      name: "index_games_on_home_team_and_starts_at"
    add_index :games, [:away_team_id, :starts_at],
      name: "index_games_on_away_team_and_starts_at"
    add_index :games, [:status, :starts_at],
      name: "index_games_on_status_and_starts_at"
    add_index :games, [:competition_id, :starts_at],
      name: "index_games_on_competition_and_starts_at"
  end
end
