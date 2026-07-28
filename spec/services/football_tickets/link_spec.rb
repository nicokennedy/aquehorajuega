require "rails_helper"

RSpec.describe FootballTickets::Link do
  let(:river) { Team.create!(name: "River Plate") }
  let(:racing) { Team.create!(name: "Racing Club") }
  let(:game) do
    Game.create!(
      home_team: river,
      away_team: racing,
      starts_at: 2.days.from_now,
      status: "scheduled"
    )
  end

  around do |example|
    keys = %w[
      FOOTBALL_TICKETS_BASE_URL
      FOOTBALL_TICKETS_TEAM_SLUGS
      FOOTBALL_TICKETS_UTM_SOURCE
      FOOTBALL_TICKETS_UTM_MEDIUM
      FOOTBALL_TICKETS_UTM_CAMPAIGN
    ]
    previous = keys.to_h { |key| [key, ENV[key]] }
    ENV["FOOTBALL_TICKETS_BASE_URL"] = "https://tickets.example.com/partidos"
    ENV["FOOTBALL_TICKETS_TEAM_SLUGS"] = "river-plate"
    ENV["FOOTBALL_TICKETS_UTM_SOURCE"] = "aquehorajuega"
    ENV["FOOTBALL_TICKETS_UTM_MEDIUM"] = "referral"
    ENV["FOOTBALL_TICKETS_UTM_CAMPAIGN"] = "equipo_o_partido"
    example.run
  ensure
    previous.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
  end

  it "construye un CTA futuro con UTMs" do
    link = described_class.for_game(game)

    expect(link.label).to eq("Buscar entradas para River Plate vs Racing Club")
    expect(link.url).to include("utm_source=aquehorajuega")
    expect(link.url).to include("utm_medium=referral")
    expect(link.url).to include("utm_campaign=equipo_o_partido_partido_")
  end

  it "no genera CTA para un partido terminado" do
    game.update!(status: "finished", starts_at: 1.day.ago)

    expect(described_class.for_game(game)).to be_nil
  end

  it "no genera CTA si la integración no está configurada" do
    ENV.delete("FOOTBALL_TICKETS_BASE_URL")

    expect(described_class.for_game(game)).to be_nil
  end
end
