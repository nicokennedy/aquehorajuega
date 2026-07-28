class GamesController < ApplicationController
  before_action :redirect_legacy_competition_slug, if: -> { params[:competition].present? }

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

    allowed_slugs = Competition::INDEXABLE_SLUGS

    @competitions = Competition
      .where(slug: allowed_slugs)
      .order(
        Arel.sql(
          "CASE slug
          WHEN 'world-cup-2026' THEN 1
          WHEN 'libertadores' THEN 2
          WHEN 'sudamericana' THEN 3
          WHEN 'liga-profesional' THEN 4
          WHEN 'copa-argentina' THEN 5
          WHEN 'champions-league' THEN 6
          ELSE 7 END"
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
      CASE competitions.slug
        WHEN 'liga-profesional' THEN 0
        WHEN 'copa-argentina' THEN 1
        WHEN 'libertadores' THEN 2
        WHEN 'sudamericana' THEN 3
        WHEN 'champions-league' THEN 4
        ELSE 5
      END
    SQL

    today_range = argentina_now.beginning_of_day.utc..argentina_now.end_of_day.utc

    today_base = base_games
      .left_joins(:competition)
      .where(starts_at: today_range)

    @today_games = today_base.order(
      Arel.sql(
        <<~SQL
          #{priority_sql},
          games.starts_at ASC
        SQL
      )
    ).limit(60)

    upcoming_threshold = @competition.present? ? argentina_now.end_of_day.utc : now
    @upcoming_games = base_games
      .joins(:competition)
      .where(status: Game::UPCOMING_STATUSES)
      .where(competitions: { slug: priority_competitions })
      .where("starts_at > ?", upcoming_threshold)
      .order(Arel.sql("#{priority_sql}, games.starts_at ASC"))
      .limit(@competition.present? ? 10 : 100)

    @recent_games = base_games
      .joins(:competition)
      .where(competitions: { slug: priority_competitions })
      .recent_results(now)
      .reverse_chronological
      .limit(@competition.present? ? 5 : 20)

    @live_games = @today_games.select(&:live?)
    @groups = []
    @priority_teams = Team.where(slug: %w[river-plate boca-juniors boca]).order(:name)

    if action_name == "groups" && @competition.present?
      @groups = Promiedos::GroupScraper.new.call(@competition.slug)
    end

    if @competition.present? && action_name == "index"
      @competition_teams = (
        @today_games.flat_map { |game| [game.home_team, game.away_team] } +
        @upcoming_games.flat_map { |game| [game.home_team, game.away_team] } +
        @recent_games.flat_map { |game| [game.home_team, game.away_team] }
      ).uniq(&:id)
      @seo = SeoMetadata.for_competition(@competition)
    elsif action_name == "today"
      @today_date = argentina_now
      @seo = SeoMetadata.for_today(argentina_now)
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
    @ticket_link = FootballTickets::Link.for_game(@game)
    @seo = SeoMetadata.for_game(game: @game, tickets_available: @ticket_link.present?)
    @home_upcoming_games = @game.home_team.games
      .includes(:home_team, :away_team, :competition)
      .future
      .where.not(id: @game.id)
      .chronological
      .limit(3)
    @away_upcoming_games = @game.away_team.games
      .includes(:home_team, :away_team, :competition)
      .future
      .where.not(id: @game.id)
      .chronological
      .limit(3)
  end

  def calendar
    @game = Game.includes(:home_team, :away_team, :competition).find_by!(slug: params[:id])

    send_data Calendar::IcsBuilder.for_game(@game),
      type: "text/calendar; charset=utf-8",
      disposition: "attachment",
      filename: "#{@game.slug}.ics"
  end

  private

  def redirect_legacy_competition_slug
    slug = params[:competition].to_s
    return unless Competition.legacy_slug?(slug)

    canonical_slug = Competition.canonical_slug(slug)
    target = case action_name
    when "groups"
      competition_groups_path(canonical_slug, locale: I18n.locale, q: params[:q])
    when "upcoming_competition"
      competition_upcoming_path(canonical_slug, locale: I18n.locale, q: params[:q])
    when "today_competition"
      competition_today_path(canonical_slug, locale: I18n.locale, q: params[:q])
    else
      competition_path(canonical_slug, locale: I18n.locale, q: params[:q], tab: params[:tab])
    end

    redirect_to target, status: :moved_permanently
  end
end
