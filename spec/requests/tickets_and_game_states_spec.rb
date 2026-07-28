require "rails_helper"

RSpec.describe "Tickets and game states", type: :request do
  let(:river) { Team.create!(name: "River Plate") }
  let(:racing) { Team.create!(name: "Racing Club") }
  let(:competition) { Competition.create!(name: "Libertadores", slug: "libertadores") }

  def game(status:, starts_at:, home_score: nil, away_score: nil)
    Game.create!(
      home_team: river,
      away_team: racing,
      competition: competition,
      starts_at: starts_at,
      status: status,
      home_score: home_score,
      away_score: away_score
    )
  end

  around do |example|
    previous_url = ENV["FOOTBALL_TICKETS_BASE_URL"]
    previous_teams = ENV["FOOTBALL_TICKETS_TEAM_SLUGS"]
    ENV["FOOTBALL_TICKETS_BASE_URL"] = "https://tickets.example.com"
    ENV["FOOTBALL_TICKETS_TEAM_SLUGS"] = "river-plate"
    example.run
  ensure
    previous_url.nil? ? ENV.delete("FOOTBALL_TICKETS_BASE_URL") : ENV["FOOTBALL_TICKETS_BASE_URL"] = previous_url
    previous_teams.nil? ? ENV.delete("FOOTBALL_TICKETS_TEAM_SLUGS") : ENV["FOOTBALL_TICKETS_TEAM_SLUGS"] = previous_teams
  end

  it "muestra CTA sponsored y offers honesto para un partido futuro habilitado" do
    match = game(status: "scheduled", starts_at: 2.days.from_now)

    get "/es/games/#{match.slug}"

    expect(response.body).to include("Buscar entradas para River Plate vs Racing Club")
    expect(response.body).to include('rel="sponsored"')
    expect(response.body).to include("utm_source=aquehorajuega")
    expect(response.body).to include('data-analytics-event="ticket_click"')
    event_json = response.body.scan(
      %r{<script type="application/ld\+json">\s*(.*?)\s*</script>}m
    ).flatten.map { |json| JSON.parse(json) }.find { |item| item["@type"] == "SportsEvent" }
    expect(event_json.dig("offers", "@type")).to eq("Offer")
    expect(event_json.dig("offers", "url")).to include("tickets.example.com")
    expect(event_json["offers"]).not_to have_key("price")
    expect(event_json["offers"]).not_to have_key("availability")
  end

  it "no muestra CTA ni offers para un partido finalizado" do
    match = game(
      status: "finished",
      starts_at: 1.day.ago,
      home_score: 2,
      away_score: 1
    )

    get "/es/games/#{match.slug}"

    expect(response.body).to include("River Plate vs Racing Club: resultado final")
    expect(response.body).not_to include("Buscar entradas")
    expect(response.body).not_to include('"offers"')
  end

  it "muestra el estado y resultado de un partido en vivo" do
    match = game(
      status: "live",
      starts_at: 1.hour.ago,
      home_score: 1,
      away_score: 0
    )
    match.update!(minute: 63)

    get "/es/games/#{match.slug}"

    expect(response.body).to include("partido en vivo")
    expect(response.body).to include("En vivo · 63")
    expect(response.body).to include("1-0")
  end
end
