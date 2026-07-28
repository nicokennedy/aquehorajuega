require "rails_helper"

RSpec.describe Competition do
  describe ".canonical_slug" do
    it "consolida los aliases conocidos" do
      expect(described_class.canonical_slug("conmebol-libertadores")).to eq("libertadores")
      expect(described_class.canonical_slug("conmebol-sudamericana")).to eq("sudamericana")
      expect(described_class.canonical_slug("fifa-world-cup")).to eq("world-cup-2026")
      expect(described_class.canonical_slug("uefa-champions-league")).to eq("champions-league")
    end
  end
end
