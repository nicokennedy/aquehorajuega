class TeamsController < ApplicationController
  def show
    @team = Team.find_by_slug!(params[:id])

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
      .future(argentina_now.end_of_day.utc)
      .chronological
      .limit(5)

    @past_games = base_games
      .recent_results(argentina_now.beginning_of_day.utc)
      .reverse_chronological
      .limit(5)

    @focus_game = @today_games.first || @upcoming_games.first
    @next_game = @upcoming_games.first
    @seo = SeoMetadata.for_team(
      team: @team,
      today_game: @today_games.first,
      next_game: @next_game
    )
    @ticket_link = FootballTickets::Link.for_team(@team, next_game: @focus_game)
  end

  def calendar
    @team = Team.find_by_slug!(params[:id])
    games = @team.games
      .includes(:home_team, :away_team, :competition)
      .future
      .chronological
      .limit(20)

    send_data Calendar::IcsBuilder.for_team(@team, games),
      type: "text/calendar; charset=utf-8",
      disposition: "attachment",
      filename: "calendario-#{@team.slug}.ics"
  end
end
