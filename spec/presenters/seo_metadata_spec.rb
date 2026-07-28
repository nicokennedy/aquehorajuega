require "rails_helper"

RSpec.describe SeoMetadata do
  let(:team) { Team.create!(name: "River Plate") }
  let(:rival) { Team.create!(name: "Racing Club") }

  it "genera metadata para un equipo que juega hoy" do
    game = Game.create!(
      home_team: team,
      away_team: rival,
      starts_at: Time.current.end_of_day - 1.hour,
      status: "scheduled"
    )

    metadata = described_class.for_team(team: team, today_game: game, next_game: nil)

    expect(metadata.h1).to eq("¿A qué hora juega River Plate hoy?")
    expect(metadata.title).to include("¿A qué hora juega River Plate hoy?")
    expect(metadata.description).to include("Racing Club")
  end

  it "genera metadata estable sin fixture" do
    metadata = described_class.for_team(team: team, today_game: nil, next_game: nil)

    expect(metadata.h1).to eq("Próximos partidos de River Plate")
    expect(metadata.title).to eq("River Plate: próximos partidos y resultados")
    expect(metadata.description).not_to include("nil")
  end

  it "diferencia partidos en vivo y finalizados" do
    game = Game.new(home_team: team, away_team: rival, starts_at: Time.current, status: "live")
    expect(described_class.for_game(game: game).title).to include("en vivo")

    game.status = "finished"
    game.home_score = 2
    game.away_score = 1
    expect(described_class.for_game(game: game).title).to include("resultado final")
  end
end
