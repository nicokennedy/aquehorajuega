SitemapGenerator::Sitemap.default_host = "https://aquehorajuega.pro"

SitemapGenerator::Sitemap.create do
  add root_path(locale: :es), changefreq: "daily", priority: 1.0
  add today_games_page_path(locale: :es), changefreq: "daily", priority: 0.95
  add upcoming_games_page_path(locale: :es), changefreq: "daily", priority: 0.9

  Competition.where(slug: Competition::INDEXABLE_SLUGS).find_each do |competition|
    next unless competition.indexable?

    add competition_path(locale: :es, competition: competition.slug),
        changefreq: "daily",
        priority: 0.85
  end

  Team.find_each do |team|
    team_name = team.name.downcase

    next if team_name.include?("group")
    next if team_name.include?("match")
    next if team_name.include?("runner")
    next if team_name.include?("3rd place")
    next unless team.indexable?

    add team_path(locale: :es, id: team),
        lastmod: team.seo_last_modified_at,
        changefreq: "daily",
        priority: 0.85
  end

  Game.includes(:home_team, :away_team, :competition)
      .where("starts_at >= ?", 7.days.ago)
      .where("starts_at <= ?", 60.days.from_now)
      .find_each do |game|

    names = [game.home_team.name, game.away_team.name].join(" ").downcase

    next if names.include?("group")
    next if names.include?("match")

    add game_path(locale: :es, id: game),
        lastmod: game.updated_at,
        changefreq: "daily",
        priority: 0.75
  end

  Game.where("starts_at >= ?", 7.days.ago)
      .where("starts_at <= ?", 60.days.from_now)
      .select("DATE(starts_at AT TIME ZONE 'America/Argentina/Buenos_Aires') as game_date")
      .distinct
      .each do |row|

    add date_games_path(locale: :es, date: row.game_date),
        changefreq: "daily",
        priority: 0.65
  end
end
