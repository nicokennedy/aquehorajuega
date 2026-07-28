require "rails_helper"

RSpec.describe Team do
  let(:team) { Team.create!(name: "River Plate") }
  let(:rival) { Team.create!(name: "Racing Club") }

  it "no indexa un equipo sin contenido deportivo" do
    expect(team).not_to be_indexable
  end

  it "indexa un equipo con resultado reciente conservado" do
    Game.create!(
      home_team: team,
      away_team: rival,
      starts_at: 3.days.ago,
      status: "finished",
      home_score: 1,
      away_score: 0
    )

    expect(team).to be_indexable
  end
end
