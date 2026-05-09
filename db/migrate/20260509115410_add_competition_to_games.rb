class AddCompetitionToGames < ActiveRecord::Migration[7.1]
  def change
    add_reference :games, :competition, foreign_key: true
  end
end
