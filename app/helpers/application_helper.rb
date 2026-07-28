module ApplicationHelper
  NOINDEX_ACTIONS = %w[upcoming_competition today_competition groups].freeze

  def canonical_url
    "#{Site::URL}#{canonical_path}"
  end

  def spanish_alternate_url
    path = request.path.sub(%r{\A/(es|en|pt)(?=/|$)}, "/es")
    path = "/es" if path == "/"
    "#{Site::URL}#{path}"
  end

  def noindex_page?
    I18n.locale != Site::INDEXABLE_LOCALE ||
      NOINDEX_ACTIONS.include?(action_name) ||
      params[:q].present? ||
      (defined?(@team) && @team.present? && !@team.indexable?)
  end

  def games_fragment_key(name, games)
    records = games.load
    [name, I18n.locale, records.size, records.map(&:updated_at).compact.max]
  end

  def competition_url_for(competition, options = {})
    competition_path(
      competition.slug,
      { locale: I18n.locale }.merge(options)
    )
  end

  private

  def canonical_path
    request.path.presence || "/"
  end
end
