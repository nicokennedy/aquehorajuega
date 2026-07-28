require "uri"

module FootballTickets
  class Link
    attr_reader :url, :label, :team

    def self.for_game(game)
      return unless FootballTickets.configured? && game.future?

      team = [game.home_team, game.away_team].find do |candidate|
        FootballTickets.enabled_team_slugs.include?(candidate.slug)
      end
      return unless team

      new(
        team: team,
        label: "Buscar entradas para #{game.home_team.name} vs #{game.away_team.name}",
        campaign: "partido_#{game.slug}"
      )
    end

    def self.for_team(team, next_game:)
      return unless FootballTickets.configured?
      return unless next_game&.future?
      return unless FootballTickets.enabled_team_slugs.include?(team.slug)

      new(
        team: team,
        label: "#{FootballTickets.cta_text} para #{team.name}",
        campaign: "equipo_#{team.slug}"
      )
    end

    def initialize(team:, label:, campaign:)
      @team = team
      @label = label
      @url = build_url(campaign)
    end

    private

    def build_url(campaign)
      uri = URI.parse(FootballTickets.base_url)
      query = URI.decode_www_form(uri.query.to_s)
      query.concat([
        ["utm_source", FootballTickets.utm_source],
        ["utm_medium", FootballTickets.utm_medium],
        ["utm_campaign", [FootballTickets.utm_campaign, campaign].join("_")]
      ])
      uri.query = URI.encode_www_form(query)
      uri.to_s
    end
  end
end
