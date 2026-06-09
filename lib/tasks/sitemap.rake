namespace :sitemap do
  desc "Regenerar sitemap y notificar a Google"
  task refresh: :environment do
    SitemapGenerator::Sitemap.verbose = false
    load Rails.root.join("config", "sitemap.rb")
    SitemapGenerator::Sitemap.ping_search_engines
    puts "Sitemap regenerado: #{Time.current}"
  end
end
