require "rails_helper"

RSpec.describe "Game SEO", type: :request do
  let(:home_team) { Team.create!(name: "Banfield") }
  let(:away_team) { Team.create!(name: "Sarmiento Junín") }
  let(:game) do
    Game.create!(
      home_team: home_team,
      away_team: away_team,
      starts_at: 2.days.from_now.change(hour: 21, min: 0),
      status: "scheduled"
    )
  end

  it "renderiza un único h1 y una description sin datos opcionales rotos" do
    get "/es/games/#{game.slug}"

    expect(response).to have_http_status(:ok)
    expect(response.body.scan("<h1").size).to eq(1)
    expect(response.body).to include("Banfield vs Sarmiento Junín: horario y detalles del partido")
    argentina_time = game.starts_at
      .in_time_zone("America/Argentina/Buenos_Aires")
      .strftime("%H:%M")
    expect(response.body).to include(argentina_time)
    description = response.body[/<meta name="description" content="([^"]+)"/, 1]
    expect(description).not_to include("hora en ")
    expect(description).not_to include("estadio  ")
    expect(description).not_to include("countdown")
  end

  it "genera SportsEvent sin location ni organizer inventados" do
    get "/es/games/#{game.slug}"

    schemas = response.body.scan(
      %r{<script type="application/ld\+json">\s*(.*?)\s*</script>}m
    ).flatten.map { |json| JSON.parse(json) }
    event = schemas.find { |schema| schema["@type"] == "SportsEvent" }

    expect(event["url"]).to eq("https://aquehorajuega.pro/es/games/#{game.slug}")
    expect(event).not_to have_key("location")
    expect(event).not_to have_key("organizer")
  end
end
