class TeamsController < ApplicationController
  def show
    @team = Team.find_by!("LOWER(REPLACE(name, ' ', '-')) = ?", params[:id].downcase)

    @upcoming_games = @team.games
      .includes(:home_team, :away_team, :competition)
      .where("starts_at > ?", Time.current)
      .order(:starts_at)

    @past_games = @team.games
      .includes(:home_team, :away_team, :competition)
      .where("starts_at <= ?", Time.current)
      .order(starts_at: :desc)
      .limit(10)
  end
end