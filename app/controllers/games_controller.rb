class GamesController < ApplicationController
  def index
    if action_name == "index"
      if params[:tab] == "upcoming" && params[:competition].present?
        return redirect_to competition_upcoming_path(params[:competition], locale: I18n.locale, q: params[:q]), status: :moved_permanently
      end

      if params[:tab] == "groups" && params[:competition].present?
        return redirect_to competition_groups_path(params[:competition], locale: I18n.locale, q: params[:q]), status: :moved_permanently
      end

      if params[:tab] == "today" && params[:competition].present?
        return redirect_to competition_today_path(params[:competition], locale: I18n.locale, q: params[:q]), status: :moved_permanently
      end
    end

    argentina_zone = Time.find_zone!("America/Argentina/Buenos_Aires")
    argentina_now = argentina_zone.now
    now = Time.current
    @query = params[:q].to_s.strip

    @matching_teams = if @query.present?
      Team.where("LOWER(name) LIKE ?", "%#{@query.downcase}%").limit(8)
    else
      Team.none
    end

    allowed_slugs = [
      "world-cup-2026",
      "conmebol-libertadores",
      "conmebol-sudamericana",
      "liga-profesional",
      "champions-league"
    ]

    @competitions = Competition
      .where(slug: allowed_slugs)
      .order(
        Arel.sql(
          "CASE slug
          WHEN 'world-cup-2026' THEN 1
          WHEN 'conmebol-libertadores' THEN 2
          WHEN 'conmebol-sudamericana' THEN 3
          WHEN 'liga-profesional' THEN 4
          WHEN 'champions-league' THEN 5
          ELSE 6 END"
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

    priority_competitions = allowed_slugs

    priority_sql = <<~SQL
      CASE
        WHEN competitions.slug IN (#{priority_competitions.map { |s| "'#{s}'" }.join(",")})
        THEN 0
        ELSE 1
      END
    SQL

    today_range = argentina_now.beginning_of_day.utc..argentina_now.end_of_day.utc

    today_base = base_games
      .joins(:competition)
      .where(starts_at: today_range)
      .where(competitions: { slug: priority_competitions })

    @today_games = today_base.order(
      Arel.sql(
        <<~SQL
          CASE
            WHEN games.status = 'live' THEN 0
            WHEN games.status = 'scheduled' THEN 1
            WHEN games.status = 'finished' THEN 2
            ELSE 3
          END,
          #{priority_sql},
          games.starts_at ASC
        SQL
      )
    )

    @upcoming_games = base_games
      .joins(:competition)
      .where(competitions: { slug: priority_competitions })
      .where("starts_at > ?", now.end_of_day)
      .order(Arel.sql("#{priority_sql}, games.starts_at ASC"))

    @live_games = @today_games.select(&:live?)
    @groups = []

    if @competition.present?
      @groups = Promiedos::GroupScraper.new.call(@competition.slug)
    end
  end

  def today
    params[:tab] = "today"
    index
    render :index
  end

  def upcoming
    params[:tab] = "upcoming"
    index
    render :index
  end

  def groups
    params[:tab] = "groups"
    index
    render :index
  end

  def upcoming_competition
    params[:tab] = "upcoming"
    index
    render :index
  end

  def today_competition
    params[:tab] = "today"
    index
    render :index
  end

  def show
    @game = Game.includes(:home_team, :away_team, :competition).find_by!(slug: params[:id])
  end
end