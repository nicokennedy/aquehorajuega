namespace :promiedos do
  task sync: :environment do
    Promiedos::SyncGames.new.call
  end

  task full_sync: :environment do
    Promiedos::FullSyncGames.new.call
  end

  task sync_live: :environment do
    Promiedos::LiveSyncGames.new.call
  end
end
namespace :world_cup do
  task populate_venues: :environment do
    ET = ActiveSupport::TimeZone["Eastern Time (US & Canada)"]

    TEAM_NAME_MAP = {
      "Mexico" => "México", "South Africa" => "Sudáfrica", "South Korea" => "Corea del Sur",
      "Czechia" => "Republica Checa", "Canada" => "Canadá", "Bosnia and Herzegovina" => "Bosnia Herzegovina",
      "USA" => "Estados Unidos", "Paraguay" => "Paraguay", "Haiti" => "Haití",
      "Scotland" => "Escocia", "Australia" => "Australia", "Türkiye" => "Turquía",
      "Brazil" => "Brasil", "Morocco" => "Marruecos", "Qatar" => "Qatar",
      "Switzerland" => "Suiza", "Ivory Coast" => "Costa de Marfil", "Ecuador" => "Ecuador",
      "Germany" => "Alemania", "Curaçao" => "Curazao", "Netherlands" => "Países Bajos",
      "Japan" => "Japón", "Sweden" => "Suecia", "Tunisia" => "Túnez",
      "Saudi Arabia" => "Arabia Saudita", "Uruguay" => "Uruguay", "Spain" => "España",
      "Cape Verde" => "Cabo Verde", "Iran" => "Irán", "New Zealand" => "Nueva Zelanda",
      "Belgium" => "Bélgica", "Egypt" => "Egipto", "France" => "Francia",
      "Senegal" => "Senegal", "Iraq" => "Irak", "Norway" => "Noruega",
      "Argentina" => "Argentina", "Algeria" => "Argelia", "Austria" => "Austria",
      "Jordan" => "Jordania", "Ghana" => "Ghana", "Panama" => "Panamá",
      "England" => "Inglaterra", "Croatia" => "Croacia", "Portugal" => "Portugal",
      "Congo DR" => "RD Congo", "Uzbekistan" => "Uzbekistán", "Colombia" => "Colombia"
    }

    games_data = [
      [1,"2026-06-11 15:00","Mexico","South Africa","Estadio Azteca","Mexico City"],
      [2,"2026-06-11 22:00","South Korea","Czechia","Estadio Akron","Guadalajara"],
      [3,"2026-06-12 15:00","Canada","Bosnia and Herzegovina","BMO Field","Toronto"],
      [4,"2026-06-12 21:00","USA","Paraguay","SoFi Stadium","Los Angeles"],
      [5,"2026-06-13 21:00","Haiti","Scotland","Gillette Stadium","Boston"],
      [6,"2026-06-13 00:00","Australia","Türkiye","BC Place","Vancouver"],
      [7,"2026-06-13 18:00","Brazil","Morocco","MetLife Stadium","New York/New Jersey"],
      [8,"2026-06-13 15:00","Qatar","Switzerland","Levi's Stadium","San Francisco Bay Area"],
      [9,"2026-06-14 19:00","Ivory Coast","Ecuador","Lincoln Financial Field","Philadelphia"],
      [10,"2026-06-14 13:00","Germany","Curaçao","NRG Stadium","Houston"],
      [11,"2026-06-14 16:00","Netherlands","Japan","AT&T Stadium","Dallas"],
      [12,"2026-06-14 22:00","Sweden","Tunisia","Estadio BBVA","Monterrey"],
      [13,"2026-06-15 18:00","Saudi Arabia","Uruguay","Hard Rock Stadium","Miami"],
      [14,"2026-06-15 12:00","Spain","Cape Verde","Mercedes-Benz Stadium","Atlanta"],
      [15,"2026-06-15 21:00","Iran","New Zealand","SoFi Stadium","Los Angeles"],
      [16,"2026-06-15 15:00","Belgium","Egypt","Lumen Field","Seattle"],
      [17,"2026-06-16 15:00","France","Senegal","MetLife Stadium","New York/New Jersey"],
      [18,"2026-06-16 18:00","Iraq","Norway","Gillette Stadium","Boston"],
      [19,"2026-06-16 21:00","Argentina","Algeria","Arrowhead Stadium","Kansas City"],
      [20,"2026-06-16 00:00","Austria","Jordan","Levi's Stadium","San Francisco Bay Area"],
      [21,"2026-06-17 19:00","Ghana","Panama","BMO Field","Toronto"],
      [22,"2026-06-17 16:00","England","Croatia","AT&T Stadium","Dallas"],
      [23,"2026-06-17 13:00","Portugal","Congo DR","NRG Stadium","Houston"],
      [24,"2026-06-17 22:00","Uzbekistan","Colombia","Estadio Azteca","Mexico City"],
      [25,"2026-06-18 12:00","Czechia","South Africa","Mercedes-Benz Stadium","Atlanta"],
      [26,"2026-06-18 15:00","Switzerland","Bosnia and Herzegovina","SoFi Stadium","Los Angeles"],
      [27,"2026-06-18 18:00","Canada","Qatar","BC Place","Vancouver"],
      [28,"2026-06-18 21:00","Mexico","South Korea","Estadio Akron","Guadalajara"],
      [29,"2026-06-19 21:00","Brazil","Haiti","Lincoln Financial Field","Philadelphia"],
      [30,"2026-06-19 18:00","Scotland","Morocco","Gillette Stadium","Boston"],
      [31,"2026-06-19 23:00","Türkiye","Paraguay","Levi's Stadium","San Francisco Bay Area"],
      [32,"2026-06-19 15:00","USA","Australia","Lumen Field","Seattle"],
      [33,"2026-06-20 16:00","Germany","Ivory Coast","BMO Field","Toronto"],
      [34,"2026-06-20 20:00","Ecuador","Curaçao","Arrowhead Stadium","Kansas City"],
      [35,"2026-06-20 13:00","Netherlands","Sweden","NRG Stadium","Houston"],
      [36,"2026-06-20 00:00","Tunisia","Japan","Estadio BBVA","Monterrey"],
      [37,"2026-06-21 18:00","Uruguay","Cape Verde","Hard Rock Stadium","Miami"],
      [38,"2026-06-21 12:00","Spain","Saudi Arabia","Mercedes-Benz Stadium","Atlanta"],
      [39,"2026-06-21 15:00","Belgium","Iran","SoFi Stadium","Los Angeles"],
      [40,"2026-06-21 21:00","New Zealand","Egypt","BC Place","Vancouver"],
      [41,"2026-06-22 20:00","Norway","Senegal","MetLife Stadium","New York/New Jersey"],
      [42,"2026-06-22 17:00","France","Iraq","Lincoln Financial Field","Philadelphia"],
      [43,"2026-06-22 13:00","Argentina","Austria","AT&T Stadium","Dallas"],
      [44,"2026-06-22 23:00","Jordan","Algeria","Levi's Stadium","San Francisco Bay Area"],
      [45,"2026-06-23 16:00","England","Ghana","Gillette Stadium","Boston"],
      [46,"2026-06-23 19:00","Panama","Croatia","BMO Field","Toronto"],
      [47,"2026-06-23 13:00","Portugal","Uzbekistan","NRG Stadium","Houston"],
      [48,"2026-06-23 22:00","Colombia","Congo DR","Estadio Akron","Guadalajara"],
      [49,"2026-06-24 18:00","Scotland","Brazil","Hard Rock Stadium","Miami"],
      [50,"2026-06-24 18:00","Morocco","Haiti","Mercedes-Benz Stadium","Atlanta"],
      [51,"2026-06-24 15:00","Switzerland","Canada","BC Place","Vancouver"],
      [52,"2026-06-24 15:00","Bosnia and Herzegovina","Qatar","Lumen Field","Seattle"],
      [53,"2026-06-24 21:00","Czechia","Mexico","Estadio Azteca","Mexico City"],
      [54,"2026-06-24 21:00","South Africa","South Korea","Estadio BBVA","Monterrey"],
      [55,"2026-06-25 16:00","Curaçao","Ivory Coast","Lincoln Financial Field","Philadelphia"],
      [56,"2026-06-25 16:00","Ecuador","Germany","MetLife Stadium","New York/New Jersey"],
      [57,"2026-06-25 19:00","Japan","Sweden","AT&T Stadium","Dallas"],
      [58,"2026-06-25 19:00","Tunisia","Netherlands","Arrowhead Stadium","Kansas City"],
      [59,"2026-06-25 22:00","Türkiye","USA","SoFi Stadium","Los Angeles"],
      [60,"2026-06-25 22:00","Paraguay","Australia","Levi's Stadium","San Francisco Bay Area"],
      [61,"2026-06-26 15:00","Norway","France","Gillette Stadium","Boston"],
      [62,"2026-06-26 15:00","Senegal","Iraq","BMO Field","Toronto"],
      [63,"2026-06-26 23:00","Egypt","Iran","Lumen Field","Seattle"],
      [64,"2026-06-26 23:00","New Zealand","Belgium","BC Place","Vancouver"],
      [65,"2026-06-26 20:00","Cape Verde","Saudi Arabia","NRG Stadium","Houston"],
      [66,"2026-06-26 20:00","Uruguay","Spain","Estadio Akron","Guadalajara"],
      [67,"2026-06-27 17:00","Panama","England","MetLife Stadium","New York/New Jersey"],
      [68,"2026-06-27 17:00","Croatia","Ghana","Lincoln Financial Field","Philadelphia"],
      [69,"2026-06-27 22:00","Algeria","Austria","Arrowhead Stadium","Kansas City"],
      [70,"2026-06-27 22:00","Jordan","Argentina","AT&T Stadium","Dallas"],
      [71,"2026-06-27 19:30","Colombia","Portugal","Hard Rock Stadium","Miami"],
      [72,"2026-06-27 19:30","Congo DR","Uzbekistan","Mercedes-Benz Stadium","Atlanta"]
    ]

    world_cup = Competition.find_by(slug: "world-cup-2026")
    updated = 0

    games_data.each do |number, kickoff_et, home_en, away_en, stadium, city|
      home_name = TEAM_NAME_MAP[home_en]
      away_name = TEAM_NAME_MAP[away_en]
      next unless home_name && away_name

      home_team = Team.find_by(name: home_name)
      away_team = Team.find_by(name: away_name)
      next unless home_team && away_team

      game = Game.joins(:competition)
        .where(competitions: { slug: "world-cup-2026" })
        .where(home_team: home_team, away_team: away_team)
        .first

      next unless game

      game.update!(city: city, stadium: stadium)
      updated += 1
    end

    puts "Actualizados: #{updated} partidos"
  end
end
