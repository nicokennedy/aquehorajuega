class GamesController < ApplicationController
  def index
    argentina_zone = Time.find_zone!("America/Argentina/Buenos_Aires")
    argentina_now = argentina_zone.now
    now = Time.current
    @query = params[:q].to_s.strip

    @matching_teams = if @query.present?
      Team.where("LOWER(name) LIKE ?", "%#{@query.downcase}%").limit(8)
    else
      Team.none
    end

    @competitions = Competition.order(
      Arel.sql(
        "CASE slug
        WHEN 'world-cup-2026' THEN 1
        WHEN 'libertadores' THEN 2
        WHEN 'sudamericana' THEN 3
        WHEN 'liga-argentina' THEN 4
        ELSE 5 END"
      )
    )
    competition_slug = params[:competition].presence

    @competition = Competition.find_by(slug: competition_slug)

    base_games = Game.includes(:home_team, :away_team, :competition)
    base_games = base_games.where(competition: @competition) if @competition.present?

    if @query.present?
      base_games = base_games
        .joins("INNER JOIN teams home_teams ON home_teams.id = games.home_team_id")
        .joins("INNER JOIN teams away_teams ON away_teams.id = games.away_team_id")
        .where(
          "LOWER(home_teams.name) LIKE :q OR LOWER(away_teams.name) LIKE :q OR LOWER(games.city) LIKE :q OR LOWER(games.stage) LIKE :q",
          q: "%#{@query.downcase}%"
        )
    end

    @live_games = base_games.where(status: "live").order(:starts_at)

    today_range = argentina_now.beginning_of_day.utc..argentina_now.end_of_day.utc

    @today_games = base_games
      .where(starts_at: today_range)
      .where.not(status: "live")
      .order(:starts_at)

    @upcoming_games = base_games
      .where("starts_at > ?", now)
      .order(:starts_at)
  end

  def show
    @game = Game.includes(:home_team, :away_team, :competition).find_by!(slug: params[:id])
  end
end