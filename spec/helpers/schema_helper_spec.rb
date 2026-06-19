require "rails_helper"

RSpec.describe SchemaHelper, type: :helper do
  let(:tz) { "America/Argentina/Buenos_Aires" }
  let(:ar) { ActiveSupport::TimeZone[tz] }

  let(:team)  { Team.new(name: "Brasil") }
  let(:rival) { Team.new(name: "Argentina") }
  let(:competition) { Competition.new(name: "Mundial 2026") }

  # Partido en hora Argentina conocida: 15 de julio 2026, 21:30.
  def game_at(month: 7, day: 15, hour: 21, min: 30, home: team, away: rival, comp: competition)
    Game.new(
      home_team: home,
      away_team: away,
      competition: comp,
      starts_at: ar.local(2026, month, day, hour, min)
    )
  end

  # Parsea el JSON-LD generado y devuelve el texto de las 3 respuestas FAQ.
  def faq_answers(json)
    parsed = JSON.parse(json)
    parsed.fetch("mainEntity").map { |q| q.dig("acceptedAnswer", "text") }
  end

  describe "#mes_en_español" do
    it "devuelve el mes en español, nunca en inglés" do
      expect(helper.mes_en_español(ar.local(2026, 7, 1), tz)).to eq("julio")
      expect(helper.mes_en_español(ar.local(2026, 6, 1), tz)).to eq("junio")
      expect(helper.mes_en_español(ar.local(2026, 12, 1), tz)).to eq("diciembre")
    end

    it "no explota con nil" do
      expect(helper.mes_en_español(nil, tz)).to be_nil
    end

    it "cubre los 12 meses sin nil" do
      (1..12).each do |m|
        expect(helper.mes_en_español(ar.local(2026, m, 1), tz)).to be_present
      end
    end
  end

  describe "#faq_schema_for_team" do
    it "cuando el equipo juega hoy: texto en español con la hora correcta" do
      json = helper.faq_schema_for_team(team, today_games: [game_at(hour: 21, min: 30)], upcoming_games: [])
      answers = faq_answers(json)

      expect(answers.first).to include("Brasil juega hoy a las 21:30hs")
      expect(answers.first).to include("hora Argentina")
      expect(answers.first).to include("contra Argentina")
      expect(json).not_to match(/Translation missing/i)
    end

    it "cuando no juega hoy pero tiene próximo partido: fecha en español (nunca en inglés)" do
      json = helper.faq_schema_for_team(team, today_games: [], upcoming_games: [game_at(month: 7, day: 15)])

      expect(json).to include("15 de julio")
      expect(json).not_to match(/\b(January|February|March|April|May|June|July|August|September|October|November|December)\b/)
      expect(json).not_to match(/Translation missing/i)
    end

    it "cubre todos los meses sin devolver inglés ni translation missing" do
      (1..12).each do |m|
        json = helper.faq_schema_for_team(team, today_games: [], upcoming_games: [game_at(month: m, day: 10)])
        expect(json).not_to match(/\b(January|February|March|April|May|June|July|August|September|October|November|December)\b/)
        expect(json).not_to match(/Translation missing/i)
      end
    end

    it "cuando el equipo no tiene ningún partido: textos fallback correctos" do
      json = helper.faq_schema_for_team(team, today_games: [], upcoming_games: [])
      answers = faq_answers(json)

      expect(answers[0]).to eq("Brasil no tiene partidos programados por el momento.")
      expect(answers[1]).to eq("No hay próximos partidos cargados para Brasil.")
      expect(answers[2]).to eq("Consultá el fixture completo de Brasil en esta página.")
      expect(json).not_to match(/Translation missing/i)
    end

    it "con competition nil no explota" do
      game = game_at(comp: nil)
      expect {
        @json = helper.faq_schema_for_team(team, today_games: [], upcoming_games: [game])
      }.not_to raise_error

      answers = faq_answers(@json)
      expect(answers[2]).to eq("Consultá el fixture completo de Brasil en esta página.")
      expect(@json).not_to match(/Translation missing/i)
    end

    it "con rival nil (partido sin rival cargado) no explota" do
      game = game_at(away: nil)
      expect {
        @json = helper.faq_schema_for_team(team, today_games: [game], upcoming_games: [game])
      }.not_to raise_error

      answers = faq_answers(@json)
      expect(answers[0]).to include("Brasil juega hoy a las 21:30hs")
      expect(answers[0]).not_to include("contra")
      expect(@json).not_to match(/Translation missing/i)
    end

    it "genera JSON-LD válido y parseable" do
      json = helper.faq_schema_for_team(team, today_games: [game_at], upcoming_games: [game_at(month: 8, day: 3)])
      parsed = JSON.parse(json)

      expect(parsed["@type"]).to eq("FAQPage")
      expect(parsed["mainEntity"].size).to eq(3)
      parsed["mainEntity"].each do |q|
        expect(q.dig("acceptedAnswer", "text")).to be_present
      end
    end
  end

  describe "#sports_event_schema" do
    it "incluye name, startDate, competitor y location correctamente" do
      json = helper.sports_event_schema(game_at(month: 7, day: 15))
      parsed = JSON.parse(json)

      expect(parsed["@type"]).to eq("SportsEvent")
      expect(parsed["name"]).to eq("Brasil vs Argentina")
      expect(parsed["startDate"]).to be_present
      expect(parsed["competitor"].map { |c| c["name"] }).to contain_exactly("Brasil", "Argentina")
      expect(parsed["location"]).to be_present
      expect(json).not_to match(/\b(January|February|March|April|May|June|July|August|September|October|November|December)\b/)
    end

    it "omite organizer cuando no hay competition (schema válido)" do
      json = helper.sports_event_schema(game_at(comp: nil))
      parsed = JSON.parse(json)

      expect(parsed).not_to have_key("organizer")
    end
  end
end
