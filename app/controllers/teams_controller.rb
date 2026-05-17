class TeamsController < ApplicationController
  def show
    @team = Team.find_by!("LOWER(REPLACE(name, ' ', '-')) = ?", params[:id].downcase)

    argentina_zone = Time.find_zone!("America/Argentina/Buenos_Aires")
    argentina_now = argentina_zone.now
    today_range = argentina_now.beginning_of_day.utc..argentina_now.end_of_day.utc

    base_games = @team.games.includes(:home_team, :away_team, :competition)

    @today_games = base_games
      .where(starts_at: today_range)
      .order(
        Arel.sql(
          <<~SQL
            CASE
              WHEN games.status = 'live' THEN 0
              WHEN games.status = 'scheduled' THEN 1
              WHEN games.status = 'finished' THEN 2
              ELSE 3
            END,
            games.starts_at ASC
          SQL
        )
      )

    @upcoming_games = base_games
      .where("starts_at > ?", argentina_now.end_of_day.utc)
      .order(:starts_at)

    @past_games = base_games
      .where("starts_at < ?", argentina_now.beginning_of_day.utc)
      .order(starts_at: :desc)
      .limit(10)
  end
end