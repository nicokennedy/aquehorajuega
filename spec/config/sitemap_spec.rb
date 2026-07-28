require "rails_helper"
require "tmpdir"
require "zlib"

RSpec.describe "Sitemap" do
  it "incluye sólo URLs canónicas, españolas e indexables" do
    active_competition = Competition.create!(name: "Libertadores", slug: "libertadores")
    home = Team.create!(name: "River Plate")
    away = Team.create!(name: "Racing Club")
    empty_team = Team.create!(name: "Equipo Vacío")
    game = Game.create!(
      home_team: home,
      away_team: away,
      competition: active_competition,
      starts_at: 2.days.from_now,
      status: "scheduled"
    )

    Dir.mktmpdir do |directory|
      original_public_path = SitemapGenerator::Sitemap.public_path
      original_sitemaps_path = SitemapGenerator::Sitemap.sitemaps_path
      SitemapGenerator::Sitemap.public_path = Pathname.new(directory)
      SitemapGenerator::Sitemap.sitemaps_path = ""

      load Rails.root.join("config/sitemap.rb")

      xml = Zlib::GzipReader.open(File.join(directory, "sitemap.xml.gz"), &:read)
      expect(xml).to include("https://aquehorajuega.pro/es/teams/#{home.slug}")
      expect(xml).to include("https://aquehorajuega.pro/es/games/#{game.slug}")
      expect(xml).to include("https://aquehorajuega.pro/es/libertadores")
      expect(xml).not_to include("teams/#{empty_team.slug}")
      expect(xml).not_to include("/today")
      expect(xml).not_to include("/en/")
      expect(xml).not_to include("/pt/")
      expect(xml).not_to include("conmebol-libertadores")
    ensure
      SitemapGenerator::Sitemap.public_path = original_public_path
      SitemapGenerator::Sitemap.sitemaps_path = original_sitemaps_path
    end
  end
end
