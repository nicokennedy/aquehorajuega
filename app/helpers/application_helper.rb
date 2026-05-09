module ApplicationHelper
  def competition_url_for(competition, options = {})
    competition_path(
      competition.slug,
      {
        locale: I18n.locale,
        tab: "upcoming"
      }.merge(options)
    )
  end
end