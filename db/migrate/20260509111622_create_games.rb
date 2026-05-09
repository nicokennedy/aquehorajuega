class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.integer :home_team_id
      t.integer :away_team_id
      t.datetime :starts_at
      t.string :status
      t.integer :home_score
      t.integer :away_score
      t.integer :minute
      t.string :stadium
      t.string :city
      t.string :stage
      t.integer :fifa_match_number

      t.timestamps
    end
  end
end
