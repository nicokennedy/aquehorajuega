SitemapGenerator::Sitemap.default_host = "https://aquehorajuega.pro"

SitemapGenerator::Sitemap.create do
  add root_path(locale: :es), changefreq: "daily", priority: 1.0

  Competition.find_each do |competition|
    add competition_path(locale: :es, competition: competition.slug),
        changefreq: "daily",
        priority: 0.8

    add competition_upcoming_path(locale: :es, competition: competition.slug),
        changefreq: "daily",
        priority: 0.8

    add competition_groups_path(locale: :es, competition: competition.slug),
        changefreq: "daily",
        priority: 0.7
  end

  Game.includes(:home_team, :away_team, :competition).find_each do |game|
    add game_path(locale: :es, id: game),
        lastmod: game.updated_at,
        changefreq: "daily",
        priority: 0.9
  end

  Team.find_each do |team|
    add team_path(locale: :es, id: team),
        lastmod: team.updated_at,
        changefreq: "daily",
        priority: 0.85
  end

  Game.select("DATE(starts_at) as game_date").distinct.each do |row|
    add date_games_path(locale: :es, date: row.game_date),
        changefreq: "daily",
        priority: 0.75
  end
end