module FootballTickets
  class << self
    def base_url
      ENV["FOOTBALL_TICKETS_BASE_URL"].presence
    end

    def enabled_team_slugs
      ENV.fetch("FOOTBALL_TICKETS_TEAM_SLUGS", "river-plate,boca-juniors,boca")
        .split(",")
        .map { |slug| slug.strip.parameterize }
        .reject(&:blank?)
    end

    def cta_text
      ENV.fetch("FOOTBALL_TICKETS_CTA_TEXT", "Ver entradas")
    end

    def utm_source
      ENV.fetch("FOOTBALL_TICKETS_UTM_SOURCE", "aquehorajuega")
    end

    def utm_medium
      ENV.fetch("FOOTBALL_TICKETS_UTM_MEDIUM", "referral")
    end

    def utm_campaign
      ENV.fetch("FOOTBALL_TICKETS_UTM_CAMPAIGN", "equipo_o_partido")
    end

    def configured?
      base_url.present?
    end
  end
end
