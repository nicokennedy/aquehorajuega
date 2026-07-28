require "rails_helper"

RSpec.describe "Teams", type: :request do
  ENGLISH_MONTHS = /\b(January|February|March|April|May|June|July|August|September|October|November|December)\b/

  let(:tz) { ActiveSupport::TimeZone["America/Argentina/Buenos_Aires"] }
  let(:competition) { Competition.create!(name: "Mundial 2026", slug: "mundial-2026") }

  let(:brasil)    { Team.create!(name: "Brasil") }
  let(:argentina) { Team.create!(name: "Argentina") }

  # Extrae el contenido del <title> aunque tenga saltos de línea alrededor.
  def title_text(body)
    body[/<title>(.*?)<\/title>/m, 1].to_s.strip
  end

  describe "GET /es/teams/brasil/today" do
    context "cuando Brasil juega hoy" do
      before do
        Game.create!(
          home_team: brasil,
          away_team: argentina,
          competition: competition,
          status: "scheduled",
          starts_at: tz.now.change(hour: 12),
          stadium: "Maracaná",
          city: "Río de Janeiro"
        )
      end

      it "redirige permanentemente a la página general" do
        get "/es/teams/brasil/today"
        expect(response).to have_http_status(:moved_permanently)
        expect(response.location).to eq("http://www.example.com/es/teams/brasil")
      end
    end

    context "cuando Brasil NO juega hoy pero tiene próximo partido" do
      before do
        Game.create!(
          home_team: brasil,
          away_team: argentina,
          competition: competition,
          status: "scheduled",
          starts_at: tz.now.change(hour: 12) + 40.days
        )
      end

      it "redirige permanentemente" do
        get "/es/teams/brasil/today"
        expect(response).to have_http_status(:moved_permanently)
      end
    end

    context "cuando Brasil no tiene ningún partido" do
      before { brasil }

      it "redirige permanentemente" do
        get "/es/teams/brasil/today"
        expect(response).to have_http_status(:moved_permanently)
      end
    end
  end

  describe "equipos con acento/ñ en el nombre (links internos no rotos)" do
    let!(:paises_bajos) { Team.create!(name: "Países Bajos") }

    it "el slug generado por to_param no tiene acentos" do
      expect(paises_bajos.to_param).to eq("paises-bajos")
    end

    it "GET /es/teams/paises-bajos/today redirige al slug correcto" do
      Game.create!(
        home_team: paises_bajos,
        away_team: Team.create!(name: "Suecia"),
        competition: competition,
        status: "scheduled",
        starts_at: tz.now.change(hour: 14)
      )

      get "/es/teams/paises-bajos/today"
      expect(response).to have_http_status(:moved_permanently)
      expect(response.location).to end_with("/es/teams/paises-bajos")
    end

    it "GET /es/teams/paises-bajos (show) devuelve 200 (no 404)" do
      get "/es/teams/paises-bajos"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "canonical URLs" do
    before { brasil }

    it "el <link rel=canonical> no incluye query string" do
      get "/es/teams/brasil?utm_source=google&x=1"
      expect(response).to have_http_status(:ok)
      canonical = response.body[/<link rel="canonical" href="([^"]*)"/, 1]
      expect(canonical).to be_present
      expect(canonical).not_to include("?")
      expect(canonical).to end_with("/es/teams/brasil")
    end

    # Nota: el trailing slash lo normaliza Rails (request.path llega sin el
    # "/" final), así que la URL con slash devuelve el mismo contenido y el
    # canonical apunta a la versión sin slash -> sin duplicados para Google.
  end

  describe "GET /es/teams/brasil (show / fixture)" do
    before do
      Game.create!(
        home_team: brasil,
        away_team: argentina,
        competition: competition,
        status: "scheduled",
        starts_at: tz.now.change(hour: 12) + 40.days
      )
    end

    it "devuelve 200 sin meses en inglés ni translation missing" do
      get "/es/teams/brasil"
      expect(response).to have_http_status(:ok)
      expect(response.body).not_to match(ENGLISH_MONTHS)
      expect(response.body).not_to match(/Translation missing/i)
      expect(title_text(response.body)).to be_present
    end
  end
end
