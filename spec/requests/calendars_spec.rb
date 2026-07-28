require "rails_helper"

RSpec.describe "Calendarios ICS", type: :request do
  let(:river) { Team.create!(name: "River Plate") }
  let(:racing) { Team.create!(name: "Racing Club") }
  let(:competition) { Competition.create!(name: "Liga Profesional Argentina", slug: "liga-profesional") }
  let(:game) do
    Game.create!(
      home_team: river,
      away_team: racing,
      competition: competition,
      starts_at: Time.zone.parse("2026-08-02 21:00:00"),
      status: "scheduled",
      stage: "Fecha 4"
    )
  end

  it "descarga el evento individual con URL y horario UTC" do
    get "/es/games/#{game.slug}/calendar.ics"

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("text/calendar")
    expect(response.headers["Content-Disposition"]).to include("#{game.slug}.ics")
    expect(response.body).to include("BEGIN:VCALENDAR")
    expect(response.body).to include("SUMMARY:River Plate vs Racing Club")
    expect(response.body).to include("DTSTART:20260802T210000Z")
    expect(response.body).to include("URL:https://aquehorajuega.pro/es/games/#{game.slug}")
  end

  it "descarga el calendario de próximos partidos del equipo" do
    game

    get "/es/teams/river-plate/calendar.ics"

    expect(response).to have_http_status(:ok)
    expect(response.headers["Content-Disposition"]).to include("calendario-river-plate.ics")
    expect(response.body).to include("X-WR-CALNAME:Próximos partidos de River Plate")
    expect(response.body.scan("BEGIN:VEVENT").size).to eq(1)
  end
end
