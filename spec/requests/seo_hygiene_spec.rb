require "rails_helper"

RSpec.describe "SEO hygiene", type: :request do
  let(:team) { Team.create!(name: "River Plate") }

  it "redirige www al host canónico preservando path y query" do
    host! "www.aquehorajuega.pro"

    get "/es/teams/river-plate?utm_source=test"

    expect(response).to have_http_status(:moved_permanently)
    expect(response.location).to eq(
      "https://aquehorajuega.pro/es/teams/river-plate?utm_source=test"
    )
  end

  it "redirige URLs públicas sin locale a español" do
    get "/"

    expect(response).to have_http_status(:moved_permanently)
    expect(response.location).to eq("https://aquehorajuega.pro/es")
  end

  it "genera canonical en el host canónico sin query string" do
    team
    host! "otro-host.test"

    get "/es/teams/river-plate?utm_source=test"

    expect(response.body).to include(
      '<link rel="canonical" href="https://aquehorajuega.pro/es/teams/river-plate">'
    )
  end

  it "publica solamente hreflang español y x-default" do
    team

    get "/es/teams/river-plate"

    expect(response.body).to include('hreflang="es"')
    expect(response.body).to include('hreflang="x-default"')
    expect(response.body).not_to include('hreflang="en"')
    expect(response.body).not_to include('hreflang="pt"')
  end

  it "marca inglés y portugués como noindex,follow" do
    team

    get "/en/teams/river-plate"
    expect(response.body).to include('<meta name="robots" content="noindex, follow">')

    get "/pt/teams/river-plate"
    expect(response.body).to include('<meta name="robots" content="noindex, follow">')
  end

  it "marca equipos vacíos como noindex,follow" do
    team

    get "/es/teams/river-plate"

    expect(response.body).to include('<meta name="robots" content="noindex, follow">')
  end

  it "permite indexar un equipo con partido futuro" do
    rival = Team.create!(name: "Racing Club")
    Game.create!(
      home_team: team,
      away_team: rival,
      starts_at: 2.days.from_now,
      status: "scheduled"
    )

    get "/es/teams/river-plate"

    expect(response.body).not_to include('<meta name="robots" content="noindex, follow">')
  end

  it "redirige slugs históricos de competiciones" do
    get "/es/conmebol-libertadores"

    expect(response).to have_http_status(:moved_permanently)
    expect(response.location).to end_with("/es/libertadores")
  end
end
