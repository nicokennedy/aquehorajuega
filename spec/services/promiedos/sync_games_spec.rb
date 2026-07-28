require "rails_helper"

RSpec.describe Promiedos::SyncGames do
  subject(:service) { described_class.new }

  let(:competition) { Competition.create!(name: "Liga", slug: "liga") }

  def game_data(start_time)
    {
      "id" => "external-1",
      "start_time" => start_time,
      "teams" => [
        { "id" => "home-1", "name" => "River Plate" },
        { "id" => "away-1", "name" => "Racing Club" }
      ],
      "status" => { "enum" => 1 },
      "scores" => [],
      "stage_round_name" => "Fecha 1",
      "filter_key" => "fixture"
    }
  end

  it "parsea siempre la fuente en America/Argentina/Buenos_Aires" do
    parsed = service.send(:parse_datetime, "28-07-2026 23:30")

    expect(parsed.time_zone.name).to eq("America/Argentina/Buenos_Aires")
    expect(parsed.strftime("%Y-%m-%d %H:%M %:z")).to eq("2026-07-28 23:30 -03:00")
  end

  it "mantiene correctamente un horario que cruza de día en UTC" do
    parsed = service.send(:parse_datetime, "28-07-2026 23:30")

    expect(parsed.utc.strftime("%Y-%m-%d %H:%M")).to eq("2026-07-29 02:30")
  end

  it "no cambia por DYNO ni entre verano e invierno argentino" do
    previous_dyno = ENV["DYNO"]
    begin
      ENV["DYNO"] = "web.1"
      summer = service.send(:parse_datetime, "15-01-2026 21:00")
      winter = service.send(:parse_datetime, "15-07-2026 21:00")

      expect(summer.utc_offset).to eq(-3.hours)
      expect(winter.utc_offset).to eq(-3.hours)
    ensure
      previous_dyno.nil? ? ENV.delete("DYNO") : ENV["DYNO"] = previous_dyno
    end
  end

  it "conserva el slug público cuando el partido es reprogramado" do
    service.send(:sync_game, game_data("28-07-2026 21:00"), competition)
    original = Game.find_by!(external_id: "external-1").slug

    service.send(:sync_game, game_data("29-07-2026 21:00"), competition)
    game = Game.find_by!(external_id: "external-1")

    expect(game.slug).to eq(original)
    expect(game.starts_at.in_time_zone("America/Argentina/Buenos_Aires").day).to eq(29)
  end

  it "conserva 180 días de resultados y elimina datos más antiguos" do
    home = Team.create!(name: "Equipo Histórico")
    away = Team.create!(name: "Rival Histórico")
    recent = Game.create!(
      home_team: home, away_team: away,
      starts_at: 179.days.ago, status: "finished"
    )
    old = Game.create!(
      home_team: away, away_team: home,
      starts_at: 181.days.ago, status: "finished"
    )
    allow(service).to receive(:scraper).and_return(double(call: []))
    allow(Promiedos::GroupScraper).to receive(:new)
      .and_return(double(sync_team_ids!: true))

    service.call

    expect(Game.exists?(recent.id)).to be(true)
    expect(Game.exists?(old.id)).to be(false)
  end
end
