require "rails_helper"
require "active_support/testing/time_helpers"

RSpec.describe "Fase 2 pages", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:river) { Team.create!(name: "River Plate") }
  let(:boca) { Team.create!(name: "Boca Juniors") }
  let(:racing) { Team.create!(name: "Racing Club") }
  let(:competition) { Competition.create!(name: "Liga Profesional Argentina", slug: "liga-profesional") }

  around do |example|
    travel_to Time.find_zone!("America/Argentina/Buenos_Aires").local(2026, 8, 1, 12, 0) do
      example.run
    end
  end

  def create_game(home:, away:, starts_at:, status:, home_score: nil, away_score: nil)
    Game.create!(
      home_team: home,
      away_team: away,
      competition: competition,
      starts_at: starts_at,
      status: status,
      home_score: home_score,
      away_score: away_score
    )
  end

  it "responde inmediatamente cuando River juega hoy" do
    game = create_game(
      home: river, away: racing,
      starts_at: 5.hours.from_now, status: "scheduled"
    )

    get "/es/teams/river-plate"

    expect(response.body).to include("<h1>¿A qué hora juega River Plate hoy?</h1>")
    expect(response.body).to include("Racing Club")
    expect(response.body).to include("Liga Profesional Argentina")
    expect(response.body).to include("Ver detalles del partido")
    expect(response.body).to include(game.slug)
  end

  it "muestra próximo partido y cinco resultados como máximo" do
    create_game(home: river, away: racing, starts_at: 3.days.from_now, status: "scheduled")
    6.times do |index|
      create_game(
        home: index.even? ? river : racing,
        away: index.even? ? racing : river,
        starts_at: (index + 1).days.ago,
        status: "finished",
        home_score: 1,
        away_score: 0
      )
    end

    get "/es/teams/river-plate"

    expect(response.body).to include("<h1>Próximo partido de River Plate</h1>")
    expect(response.body).to include("Últimos resultados de River Plate")
    expect(response.body.scan("status-finished").size).to eq(5)
  end

  it "explica la ausencia de fixture sin inventar rival o fecha" do
    river
    get "/es/teams/river-plate"

    expect(response.body).to include("No hay un próximo partido confirmado")
    expect(response.body).to include('<meta name="robots" content="noindex, follow">')
  end

  it "jerarquiza partidos de hoy y enlaza River y Boca" do
    create_game(home: river, away: racing, starts_at: 4.hours.from_now, status: "scheduled")
    create_game(home: boca, away: racing, starts_at: 6.hours.from_now, status: "scheduled")

    get "/es/partidos-de-hoy"

    expect(response.body).to match(%r{<h1>\s*Partidos de hoy\s*</h1>})
    expect(response.body).to include("Liga Profesional Argentina")
    expect(response.body).to include("River Plate")
    expect(response.body).to include("Boca Juniors")
    expect(response.body).to include('data-analytics-source="today"')
  end

  it "muestra hoy, próximos, resultados y equipos en la competición" do
    create_game(home: river, away: racing, starts_at: 4.hours.from_now, status: "scheduled")
    create_game(home: boca, away: racing, starts_at: 3.days.from_now, status: "scheduled")
    create_game(home: river, away: boca, starts_at: 2.days.ago, status: "finished", home_score: 2, away_score: 1)

    get "/es/liga-profesional"

    expect(response.body).to match(%r{<h1>\s*Liga Profesional Argentina\s*</h1>})
    expect(response.body).to include("Partidos de hoy de Liga Profesional Argentina")
    expect(response.body).to include("Próximos partidos")
    expect(response.body).to include("Últimos resultados")
    expect(response.body).to include("Equipos de Liga Profesional Argentina")
  end
end
