Team.destroy_all
Game.destroy_all

ET = ActiveSupport::TimeZone["Eastern Time (US & Canada)"]

FLAGS = {
  "Mexico" => "🇲🇽", "South Africa" => "🇿🇦", "South Korea" => "🇰🇷", "Czechia" => "🇨🇿",
  "Canada" => "🇨🇦", "Bosnia and Herzegovina" => "🇧🇦", "USA" => "🇺🇸", "Paraguay" => "🇵🇾",
  "Haiti" => "🇭🇹", "Scotland" => "🏴󠁧󠁢󠁳󠁣󠁴󠁿", "Australia" => "🇦🇺", "Türkiye" => "🇹🇷",
  "Brazil" => "🇧🇷", "Morocco" => "🇲🇦", "Qatar" => "🇶🇦", "Switzerland" => "🇨🇭",
  "Ivory Coast" => "🇨🇮", "Ecuador" => "🇪🇨", "Germany" => "🇩🇪", "Curaçao" => "🇨🇼",
  "Netherlands" => "🇳🇱", "Japan" => "🇯🇵", "Sweden" => "🇸🇪", "Tunisia" => "🇹🇳",
  "Saudi Arabia" => "🇸🇦", "Uruguay" => "🇺🇾", "Spain" => "🇪🇸", "Cape Verde" => "🇨🇻",
  "Iran" => "🇮🇷", "New Zealand" => "🇳🇿", "Belgium" => "🇧🇪", "Egypt" => "🇪🇬",
  "France" => "🇫🇷", "Senegal" => "🇸🇳", "Iraq" => "🇮🇶", "Norway" => "🇳🇴",
  "Argentina" => "🇦🇷", "Algeria" => "🇩🇿", "Austria" => "🇦🇹", "Jordan" => "🇯🇴",
  "Ghana" => "🇬🇭", "Panama" => "🇵🇦", "England" => "🏴", "Croatia" => "🇭🇷",
  "Portugal" => "🇵🇹", "Congo DR" => "🇨🇩", "Uzbekistan" => "🇺🇿", "Colombia" => "🇨🇴"
}

CLUB_COLORS = {
  "River Plate" => ["#E2231A", "#FFFFFF"],
  "Boca Juniors" => ["#0033A0", "#F7D117"],
  "Racing Club" => ["#6EC1E4", "#FFFFFF"],
  "Independiente" => ["#D71920", "#FFFFFF"],
  "San Lorenzo" => ["#1D2E6E", "#C62828"],
  "Vélez Sarsfield" => ["#1F3A93", "#FFFFFF"],
  "Estudiantes" => ["#D71920", "#FFFFFF"],
  "Rosario Central" => ["#1E90FF", "#FFD700"],
  "Newell's" => ["#D71920", "#000000"],
  "Belgrano" => ["#6EC1E4", "#6EC1E4"],
  "Talleres" => ["#1F3A93", "#FFFFFF"],

  "Flamengo" => ["#C62828", "#000000"],
  "Fluminense" => ["#7A1E48", "#006B3F"],
  "Palmeiras" => ["#006437", "#FFFFFF"],
  "Corinthians" => ["#111111", "#FFFFFF"],
  "Santos" => ["#FFFFFF", "#111111"],
  "Grêmio" => ["#00AEEF", "#000000"],
  "Internacional" => ["#C62828", "#FFFFFF"],
  "Botafogo" => ["#111111", "#FFFFFF"],
  "Cruzeiro" => ["#1D4ED8", "#FFFFFF"],
  "Atlético Mineiro" => ["#111111", "#FFFFFF"],
  "Vasco da Gama" => ["#111111", "#FFFFFF"],

  "Nacional" => ["#FFFFFF", "#1D4ED8"],
  "Peñarol" => ["#F7D117", "#111111"],

  "Olimpia" => ["#111111", "#FFFFFF"],
  "Cerro Porteño" => ["#C62828", "#1D4ED8"],

  "Colo-Colo" => ["#FFFFFF", "#111111"],
  "Universidad de Chile" => ["#1D4ED8", "#FFFFFF"],
  "Universidad Católica" => ["#1D4ED8", "#FFFFFF"],

  "Bolívar" => ["#6EC1E4", "#FFFFFF"],
  "The Strongest" => ["#F7D117", "#111111"],

  "Alianza Lima" => ["#1D4ED8", "#FFFFFF"],
  "Sporting Cristal" => ["#6EC1E4", "#FFFFFF"],
  "Universitario" => ["#F4E4C1", "#7A1E48"],

  "Atlético Nacional" => ["#006437", "#FFFFFF"],
  "Millonarios" => ["#1D4ED8", "#FFFFFF"],
  "América de Cali" => ["#D71920", "#FFFFFF"],

  "Barcelona SC" => ["#F7D117", "#111111"],
  "LDU Quito" => ["#FFFFFF", "#D71920"],
  "Emelec" => ["#1D4ED8", "#FFFFFF"],

  "Deportivo Táchira" => ["#F7D117", "#111111"],
  "Caracas FC" => ["#C62828", "#FFFFFF"],

  "Libertad" => ["#111111", "#FFFFFF"],
  "Junior" => ["#D71920", "#FFFFFF"],
  "Independiente Medellín" => ["#D71920", "#1D4ED8"],
  "Cusco" => ["#F7D117", "#111111"],
  "Coquimbo Unido" => ["#F7D117", "#111111"],
  "Deportes Tolima" => ["#7A1E48", "#F7D117"],
  "Deportivo La Guaira" => ["#F97316", "#FFFFFF"],
  "Independiente Rivadavia" => ["#1D4ED8", "#FFFFFF"],
  "Independiente del Valle" => ["#111111", "#1D4ED8"],
  "Universidad Central" => ["#D71920", "#FFFFFF"],
  "Always Ready" => ["#D71920", "#FFFFFF"],
  "Mirassol" => ["#F7D117", "#006437"],
  "Lanús" => ["#7A1E48", "#FFFFFF"],
  "Tigre" => ["#1D4ED8", "#D71920"],
  "Macará" => ["#6EC1E4", "#FFFFFF"],
  "Alianza Atlético" => ["#1D4ED8", "#FFFFFF"],
  "Puerto Cabello" => ["#F97316", "#111111"],
  "Cienciano" => ["#D71920", "#FFFFFF"],
  "Juventud" => ["#006437", "#FFFFFF"],
  "Boston River" => ["#006437", "#D71920"],
  "O'Higgins" => ["#6EC1E4", "#FFFFFF"],
  "Deportivo Cuenca" => ["#D71920", "#111111"],
  "Recoleta" => ["#006437", "#FFFFFF"],
  "Independiente Petrolero" => ["#D71920", "#FFFFFF"],
  "Montevideo City Torque" => ["#6EC1E4", "#111111"],
  "Deportivo Riestra" => ["#111111", "#FFFFFF"],
  "Palestino" => ["#006437", "#D71920"],
  "Audax Italiano" => ["#006437", "#FFFFFF"],
  "Barracas Central" => ["#D71920", "#FFFFFF"],
  "Blooming" => ["#6EC1E4", "#FFFFFF"],
  "Carabobo" => ["#D71920", "#FFFFFF"],
  "Bragantino" => ["#FFFFFF", "#111111"],
  "São Paulo" => ["#FFFFFF", "#D71920"],
  "Argentinos Juniors" => ["#D71920", "#FFFFFF"],
  "Huracán" => ["#FFFFFF", "#D71920"],
  "Unión de Santa Fe" => ["#D71920", "#FFFFFF"],
  "Gimnasia La Plata" => ["#FFFFFF", "#1D4ED8"],
}


def team_for(name)
  team = Team.find_or_initialize_by(name: name)

  team.code = name.parameterize.upcase.first(12)
  team.flag = FLAGS[name]

  if CLUB_COLORS[name]
    team.primary_color = CLUB_COLORS[name][0]
    team.secondary_color = CLUB_COLORS[name][1]
  end

  team.save!

  team
end

LIBERTADORES_TEAMS = [
  "River Plate",
  "Boca Juniors",
  "Racing Club",
  "Independiente",
  "San Lorenzo",
  "Vélez Sarsfield",
  "Estudiantes",
  "Rosario Central",
  "Newell's",
  "Belgrano",
  "Talleres",
  "Flamengo",
  "Fluminense",
  "Palmeiras",
  "Corinthians",
  "São Paulo",
  "Santos",
  "Grêmio",
  "Internacional",
  "Botafogo",
  "Cruzeiro",
  "Atlético Mineiro",
  "Vasco da Gama",
  "Nacional",
  "Peñarol",
  "Olimpia",
  "Cerro Porteño",
  "Colo-Colo",
  "Universidad de Chile",
  "Universidad Católica",
  "Bolívar",
  "The Strongest",
  "Alianza Lima",
  "Sporting Cristal",
  "Universitario",
  "Atlético Nacional",
  "Millonarios",
  "América de Cali",
  "Barcelona SC",
  "LDU Quito",
  "Emelec",
  "Deportivo Táchira",
  "Caracas FC",
  "Libertad",
  "Junior"
]

LIBERTADORES_TEAMS.each do |team_name|
  team_for(team_name)
end

games = [
  [1,"2026-06-11 15:00","Mexico","South Africa","A","Estadio Azteca","Mexico City"],
  [2,"2026-06-11 22:00","South Korea","Czechia","A","Estadio Akron","Guadalajara"],
  [3,"2026-06-12 15:00","Canada","Bosnia and Herzegovina","B","BMO Field","Toronto"],
  [4,"2026-06-12 21:00","USA","Paraguay","D","SoFi Stadium","Los Angeles"],
  [5,"2026-06-13 21:00","Haiti","Scotland","C","Gillette Stadium","Boston"],
  [6,"2026-06-13 00:00","Australia","Türkiye","D","BC Place","Vancouver"],
  [7,"2026-06-13 18:00","Brazil","Morocco","C","MetLife Stadium","New York/New Jersey"],
  [8,"2026-06-13 15:00","Qatar","Switzerland","B","Levi's Stadium","San Francisco Bay Area"],
  [9,"2026-06-14 19:00","Ivory Coast","Ecuador","E","Lincoln Financial Field","Philadelphia"],
  [10,"2026-06-14 13:00","Germany","Curaçao","E","NRG Stadium","Houston"],
  [11,"2026-06-14 16:00","Netherlands","Japan","F","AT&T Stadium","Dallas"],
  [12,"2026-06-14 22:00","Sweden","Tunisia","F","Estadio BBVA","Monterrey"],
  [13,"2026-06-15 18:00","Saudi Arabia","Uruguay","H","Hard Rock Stadium","Miami"],
  [14,"2026-06-15 12:00","Spain","Cape Verde","H","Mercedes-Benz Stadium","Atlanta"],
  [15,"2026-06-15 21:00","Iran","New Zealand","G","SoFi Stadium","Los Angeles"],
  [16,"2026-06-15 15:00","Belgium","Egypt","G","Lumen Field","Seattle"],
  [17,"2026-06-16 15:00","France","Senegal","I","MetLife Stadium","New York/New Jersey"],
  [18,"2026-06-16 18:00","Iraq","Norway","I","Gillette Stadium","Boston"],
  [19,"2026-06-16 21:00","Argentina","Algeria","J","Arrowhead Stadium","Kansas City"],
  [20,"2026-06-16 00:00","Austria","Jordan","J","Levi's Stadium","San Francisco Bay Area"],
  [21,"2026-06-17 19:00","Ghana","Panama","L","BMO Field","Toronto"],
  [22,"2026-06-17 16:00","England","Croatia","L","AT&T Stadium","Dallas"],
  [23,"2026-06-17 13:00","Portugal","Congo DR","K","NRG Stadium","Houston"],
  [24,"2026-06-17 22:00","Uzbekistan","Colombia","K","Estadio Azteca","Mexico City"],
  [25,"2026-06-18 12:00","Czechia","South Africa","A","Mercedes-Benz Stadium","Atlanta"],
  [26,"2026-06-18 15:00","Switzerland","Bosnia and Herzegovina","B","SoFi Stadium","Los Angeles"],
  [27,"2026-06-18 18:00","Canada","Qatar","B","BC Place","Vancouver"],
  [28,"2026-06-18 21:00","Mexico","South Korea","A","Estadio Akron","Guadalajara"],
  [29,"2026-06-19 21:00","Brazil","Haiti","C","Lincoln Financial Field","Philadelphia"],
  [30,"2026-06-19 18:00","Scotland","Morocco","C","Gillette Stadium","Boston"],
  [31,"2026-06-19 23:00","Türkiye","Paraguay","D","Levi's Stadium","San Francisco Bay Area"],
  [32,"2026-06-19 15:00","USA","Australia","D","Lumen Field","Seattle"],
  [33,"2026-06-20 16:00","Germany","Ivory Coast","E","BMO Field","Toronto"],
  [34,"2026-06-20 20:00","Ecuador","Curaçao","E","Arrowhead Stadium","Kansas City"],
  [35,"2026-06-20 13:00","Netherlands","Sweden","F","NRG Stadium","Houston"],
  [36,"2026-06-20 00:00","Tunisia","Japan","F","Estadio BBVA","Monterrey"],
  [37,"2026-06-21 18:00","Uruguay","Cape Verde","H","Hard Rock Stadium","Miami"],
  [38,"2026-06-21 12:00","Spain","Saudi Arabia","H","Mercedes-Benz Stadium","Atlanta"],
  [39,"2026-06-21 15:00","Belgium","Iran","G","SoFi Stadium","Los Angeles"],
  [40,"2026-06-21 21:00","New Zealand","Egypt","G","BC Place","Vancouver"],
  [41,"2026-06-22 20:00","Norway","Senegal","I","MetLife Stadium","New York/New Jersey"],
  [42,"2026-06-22 17:00","France","Iraq","I","Lincoln Financial Field","Philadelphia"],
  [43,"2026-06-22 13:00","Argentina","Austria","J","AT&T Stadium","Dallas"],
  [44,"2026-06-22 23:00","Jordan","Algeria","J","Levi's Stadium","San Francisco Bay Area"],
  [45,"2026-06-23 16:00","England","Ghana","L","Gillette Stadium","Boston"],
  [46,"2026-06-23 19:00","Panama","Croatia","L","BMO Field","Toronto"],
  [47,"2026-06-23 13:00","Portugal","Uzbekistan","K","NRG Stadium","Houston"],
  [48,"2026-06-23 22:00","Colombia","Congo DR","K","Estadio Akron","Guadalajara"],
  [49,"2026-06-24 18:00","Scotland","Brazil","C","Hard Rock Stadium","Miami"],
  [50,"2026-06-24 18:00","Morocco","Haiti","C","Mercedes-Benz Stadium","Atlanta"],
  [51,"2026-06-24 15:00","Switzerland","Canada","B","BC Place","Vancouver"],
  [52,"2026-06-24 15:00","Bosnia and Herzegovina","Qatar","B","Lumen Field","Seattle"],
  [53,"2026-06-24 21:00","Czechia","Mexico","A","Estadio Azteca","Mexico City"],
  [54,"2026-06-24 21:00","South Africa","South Korea","A","Estadio BBVA","Monterrey"],
  [55,"2026-06-25 16:00","Curaçao","Ivory Coast","E","Lincoln Financial Field","Philadelphia"],
  [56,"2026-06-25 16:00","Ecuador","Germany","E","MetLife Stadium","New York/New Jersey"],
  [57,"2026-06-25 19:00","Japan","Sweden","F","AT&T Stadium","Dallas"],
  [58,"2026-06-25 19:00","Tunisia","Netherlands","F","Arrowhead Stadium","Kansas City"],
  [59,"2026-06-25 22:00","Türkiye","USA","D","SoFi Stadium","Los Angeles"],
  [60,"2026-06-25 22:00","Paraguay","Australia","D","Levi's Stadium","San Francisco Bay Area"],
  [61,"2026-06-26 15:00","Norway","France","I","Gillette Stadium","Boston"],
  [62,"2026-06-26 15:00","Senegal","Iraq","I","BMO Field","Toronto"],
  [63,"2026-06-26 23:00","Egypt","Iran","G","Lumen Field","Seattle"],
  [64,"2026-06-26 23:00","New Zealand","Belgium","G","BC Place","Vancouver"],
  [65,"2026-06-26 20:00","Cape Verde","Saudi Arabia","H","NRG Stadium","Houston"],
  [66,"2026-06-26 20:00","Uruguay","Spain","H","Estadio Akron","Guadalajara"],
  [67,"2026-06-27 17:00","Panama","England","L","MetLife Stadium","New York/New Jersey"],
  [68,"2026-06-27 17:00","Croatia","Ghana","L","Lincoln Financial Field","Philadelphia"],
  [69,"2026-06-27 22:00","Algeria","Austria","J","Arrowhead Stadium","Kansas City"],
  [70,"2026-06-27 22:00","Jordan","Argentina","J","AT&T Stadium","Dallas"],
  [71,"2026-06-27 19:30","Colombia","Portugal","K","Hard Rock Stadium","Miami"],
  [72,"2026-06-27 19:30","Congo DR","Uzbekistan","K","Mercedes-Benz Stadium","Atlanta"],

  [73,"2026-06-28 15:00","Group A Runners Up","Group B Runners Up","Round of 32","SoFi Stadium","Los Angeles"],
  [74,"2026-06-29 16:30","Group E Winners","Group A/B/C/D/F 3rd Place","Round of 32","Gillette Stadium","Boston"],
  [75,"2026-06-29 21:00","Group F Winners","Group C Runners Up","Round of 32","Estadio BBVA","Monterrey"],
  [76,"2026-06-29 13:00","Group C Winners","Group F Runners Up","Round of 32","NRG Stadium","Houston"],
  [77,"2026-06-30 17:00","Group I Winners","Group C/D/F/G/H 3rd Place","Round of 32","MetLife Stadium","New York/New Jersey"],
  [78,"2026-06-30 13:00","Group E Runners Up","Group I Runners Up","Round of 32","AT&T Stadium","Dallas"],
  [79,"2026-06-30 21:00","Group A Winners","Group C/E/F/H/I 3rd Place","Round of 32","Estadio Azteca","Mexico City"],
  [80,"2026-07-01 12:00","Group L Winners","Group E/H/I/J/K 3rd Place","Round of 32","Mercedes-Benz Stadium","Atlanta"],
  [81,"2026-07-01 20:00","Group D Winners","Group B/E/F/I/J 3rd Place","Round of 32","Levi's Stadium","San Francisco Bay Area"],
  [82,"2026-07-01 16:00","Group G Winners","Group A/E/H/I/J 3rd Place","Round of 32","Lumen Field","Seattle"],
  [83,"2026-07-02 19:00","Group K Runners Up","Group L Runners Up","Round of 32","BMO Field","Toronto"],
  [84,"2026-07-02 15:00","Group H Winners","Group J Runners Up","Round of 32","SoFi Stadium","Los Angeles"],
  [85,"2026-07-02 23:00","Group B Winners","Group E/F/G/I/J 3rd Place","Round of 32","BC Place","Vancouver"],
  [86,"2026-07-03 18:00","Group J Winners","Group H Runners Up","Round of 32","Hard Rock Stadium","Miami"],
  [87,"2026-07-03 21:30","Group K Winners","Group D/E/I/J/L 3rd Place","Round of 32","Arrowhead Stadium","Kansas City"],
  [88,"2026-07-03 14:00","Group D Runners Up","Group G Runners Up","Round of 32","AT&T Stadium","Dallas"],

  [89,"2026-07-04 17:00","Match 74 Winner","Match 77 Winner","Round of 16","Lincoln Financial Field","Philadelphia"],
  [90,"2026-07-04 13:00","Match 73 Winner","Match 75 Winner","Round of 16","NRG Stadium","Houston"],
  [91,"2026-07-05 16:00","Match 76 Winner","Match 78 Winner","Round of 16","MetLife Stadium","New York/New Jersey"],
  [92,"2026-07-05 20:00","Match 79 Winner","Match 80 Winner","Round of 16","Estadio Azteca","Mexico City"],
  [93,"2026-07-06 15:00","Match 83 Winner","Match 84 Winner","Round of 16","AT&T Stadium","Dallas"],
  [94,"2026-07-06 20:00","Match 81 Winner","Match 82 Winner","Round of 16","Lumen Field","Seattle"],
  [95,"2026-07-07 12:00","Match 86 Winner","Match 88 Winner","Round of 16","Mercedes-Benz Stadium","Atlanta"],
  [96,"2026-07-07 16:00","Match 85 Winner","Match 87 Winner","Round of 16","BC Place","Vancouver"],

  [97,"2026-07-09 16:00","Match 89 Winner","Match 90 Winner","Quarter-finals","Gillette Stadium","Boston"],
  [98,"2026-07-10 15:00","Match 93 Winner","Match 94 Winner","Quarter-finals","SoFi Stadium","Los Angeles"],
  [99,"2026-07-11 17:00","Match 91 Winner","Match 92 Winner","Quarter-finals","Hard Rock Stadium","Miami"],
  [100,"2026-07-11 21:00","Match 95 Winner","Match 96 Winner","Quarter-finals","Arrowhead Stadium","Kansas City"],

  [101,"2026-07-14 15:00","Match 97 Winner","Match 98 Winner","Semi-finals","AT&T Stadium","Dallas"],
  [102,"2026-07-15 15:00","Match 99 Winner","Match 100 Winner","Semi-finals","Mercedes-Benz Stadium","Atlanta"],
  [103,"2026-07-18 17:00","Match 101 Loser","Match 102 Loser","Third Place","Hard Rock Stadium","Miami"],
  [104,"2026-07-19 15:00","Match 101 Winner","Match 102 Winner","Final","MetLife Stadium","New York/New Jersey"]
]



world_cup = Competition.find_or_create_by!(slug: "world-cup-2026") do |c|
  c.name = "Mundial 2026"
end

games.each do |number, kickoff_et, home, away, stage, stadium, city|
  Game.create!(
    competition: world_cup,
    fifa_match_number: number,
    home_team: team_for(home),
    away_team: team_for(away),
    starts_at: ET.parse(kickoff_et).utc,
    stadium: stadium,
    city: city,
    stage: stage.start_with?("Group") ? "Group #{stage}" : stage,
    status: "scheduled"
  )
end

puts "Created #{Team.count} teams/placeholders"
puts "Created #{Game.count} games"


libertadores = Competition.find_or_create_by!(slug: "libertadores") { |c| c.name = "Libertadores" }
sudamericana = Competition.find_or_create_by!(slug: "sudamericana") { |c| c.name = "Sudamericana" }
liga_argentina = Competition.find_or_create_by!(slug: "liga-argentina") { |c| c.name = "Liga Argentina" }

def create_game!(competition:, number:, home:, away:, starts_at:, stadium:, city:, stage:)
  Game.find_or_create_by!(
    competition: competition,
    fifa_match_number: number
  ) do |game|
    game.home_team = team_for(home)
    game.away_team = team_for(away)
    game.starts_at = Time.zone.parse(starts_at)
    game.stadium = stadium
    game.city = city
    game.stage = stage
    game.status = "scheduled"
  end
end


sudamericana_games = [
  [2101, "América de Cali", "Tigre", "2026-05-20 00:00:00 UTC", "Estadio Pascual Guerrero", "Cali", "Group A"],
  [2102, "Macará", "Alianza Atlético", "2026-05-22 00:00:00 UTC", "Estadio Bellavista", "Ambato", "Group A"],
  [2103, "América de Cali", "Macará", "2026-05-28 22:30:00 UTC", "Estadio Pascual Guerrero", "Cali", "Group A"],
  [2104, "Tigre", "Alianza Atlético", "2026-05-29 00:30:00 UTC", "Estadio José Dellagiovanna", "Victoria", "Group A"],

  [2201, "Atlético Mineiro", "Cienciano", "2026-05-21 22:00:00 UTC", "Estadio MRV", "Belo Horizonte", "Group B"],
  [2202, "Puerto Cabello", "Juventud", "2026-05-21 22:00:00 UTC", "Estadio Misael Delgado", "Valencia", "Group B"],
  [2203, "Atlético Mineiro", "Puerto Cabello", "2026-05-27 22:00:00 UTC", "Estadio MRV", "Belo Horizonte", "Group B"],
  [2204, "Cienciano", "Juventud", "2026-05-27 22:00:00 UTC", "Estadio Garcilaso de la Vega", "Cusco", "Group B"],

  [2301, "São Paulo", "Millonarios", "2026-05-20 00:30:00 UTC", "Estadio Morumbis", "São Paulo", "Group C"],
  [2302, "Boston River", "O'Higgins", "2026-05-20 22:00:00 UTC", "Estadio Centenario", "Montevideo", "Group C"],
  [2303, "São Paulo", "Boston River", "2026-05-26 22:00:00 UTC", "Estadio Morumbis", "São Paulo", "Group C"],
  [2304, "Millonarios", "O'Higgins", "2026-05-26 22:00:00 UTC", "Estadio El Campín", "Bogotá", "Group C"],

  [2401, "Santos", "San Lorenzo", "2026-05-20 22:00:00 UTC", "Estadio Urbano Caldeira", "Santos", "Group D"],
  [2402, "Deportivo Cuenca", "Recoleta", "2026-05-20 02:00:00 UTC", "Estadio Alejandro Serrano Aguilar", "Cuenca", "Group D"],
  [2403, "Santos", "Deportivo Cuenca", "2026-05-27 00:30:00 UTC", "Estadio Urbano Caldeira", "Santos", "Group D"],
  [2404, "San Lorenzo", "Recoleta", "2026-05-27 00:30:00 UTC", "Estadio Pedro Bidegain", "Buenos Aires", "Group D"],

  [2501, "Racing Club", "Caracas FC", "2026-05-22 00:00:00 UTC", "Estadio Presidente Perón", "Avellaneda", "Group E"],
  [2502, "Independiente Petrolero", "Botafogo", "2026-05-21 00:30:00 UTC", "Estadio Olímpico Patria", "Sucre", "Group E"],
  [2503, "Racing Club", "Independiente Petrolero", "2026-05-27 22:00:00 UTC", "Estadio Presidente Perón", "Avellaneda", "Group E"],
  [2504, "Caracas FC", "Botafogo", "2026-05-27 22:00:00 UTC", "Estadio Olímpico de la UCV", "Caracas", "Group E"],

  [2601, "Grêmio", "Palestino", "2026-05-21 00:00:00 UTC", "Arena do Grêmio", "Porto Alegre", "Group F"],
  [2602, "Montevideo City Torque", "Deportivo Riestra", "2026-05-19 22:00:00 UTC", "Estadio Centenario", "Montevideo", "Group F"],
  [2603, "Grêmio", "Montevideo City Torque", "2026-05-26 22:00:00 UTC", "Arena do Grêmio", "Porto Alegre", "Group F"],
  [2604, "Palestino", "Deportivo Riestra", "2026-05-27 00:30:00 UTC", "Estadio a definir", "Santiago", "Group F"],

  [2701, "Olimpia", "Vasco da Gama", "2026-05-21 00:00:00 UTC", "Estadio Defensores del Chaco", "Asunción", "Group G"],
  [2702, "Audax Italiano", "Barracas Central", "2026-05-19 22:00:00 UTC", "Estadio Bicentenario de La Florida", "Santiago", "Group G"],
  [2703, "Olimpia", "Audax Italiano", "2026-05-28 00:30:00 UTC", "Estadio Defensores del Chaco", "Asunción", "Group G"],
  [2704, "Vasco da Gama", "Barracas Central", "2026-05-28 00:30:00 UTC", "Estadio São Januário", "Río de Janeiro", "Group G"],

  [2801, "River Plate", "Bragantino", "2026-05-21 00:30:00 UTC", "Estadio Más Monumental", "Buenos Aires", "Group H"],
  [2802, "Blooming", "Carabobo", "2026-05-22 00:30:00 UTC", "Estadio Ramón Aguilera Costas", "Santa Cruz de la Sierra", "Group H"],
  [2803, "River Plate", "Blooming", "2026-05-28 00:30:00 UTC", "Estadio Más Monumental", "Buenos Aires", "Group H"],
  [2804, "Bragantino", "Carabobo", "2026-05-28 00:30:00 UTC", "Estadio Municipal Cícero de Souza Marques", "Bragança Paulista", "Group H"]
]

sudamericana_games.each do |number, home, away, starts_at, stadium, city, stage|
  create_game!(
    competition: sudamericana,
    number: number,
    home: home,
    away: away,
    starts_at: starts_at,
    stadium: stadium,
    city: city,
    stage: stage
  )
end

libertadores_games = [
  [1101, "Flamengo", "Estudiantes", "2026-05-21 21:30:00 UTC", "Estadio Maracaná", "Río de Janeiro", "Group A"],
  [1102, "Cusco", "Independiente Medellín", "2026-05-21 23:00:00 UTC", "Estadio Inca Garcilaso de la Vega", "Cusco", "Group A"],
  [1103, "Flamengo", "Cusco", "2026-05-26 21:30:00 UTC", "Estadio Maracaná", "Río de Janeiro", "Group A"],
  [1104, "Estudiantes", "Independiente Medellín", "2026-05-26 21:30:00 UTC", "Estadio UNO Jorge Luis Hirschi", "La Plata", "Group A"],

  [1201, "Nacional", "Universitario", "2026-05-20 19:00:00 UTC", "Estadio Gran Parque Central", "Montevideo", "Group B"],
  [1202, "Coquimbo Unido", "Deportes Tolima", "2026-05-19 19:00:00 UTC", "Estadio Francisco Sánchez Rumoroso", "Coquimbo", "Group B"],
  [1203, "Nacional", "Coquimbo Unido", "2026-05-26 21:30:00 UTC", "Estadio Gran Parque Central", "Montevideo", "Group B"],
  [1204, "Universitario", "Deportes Tolima", "2026-05-26 21:30:00 UTC", "Estadio 'U' Marathon", "Lima", "Group B"],

  [1301, "Fluminense", "Bolívar", "2026-05-19 19:00:00 UTC", "Estadio Maracaná", "Río de Janeiro", "Group C"],
  [1302, "Deportivo La Guaira", "Independiente Rivadavia", "2026-05-21 19:00:00 UTC", "Estadio Olímpico de la UCV", "Caracas", "Group C"],
  [1303, "Fluminense", "Deportivo La Guaira", "2026-05-27 21:30:00 UTC", "Estadio Maracaná", "Río de Janeiro", "Group C"],
  [1304, "Bolívar", "Independiente Rivadavia", "2026-05-27 21:30:00 UTC", "Estadio Hernando Siles", "La Paz", "Group C"],

  [1401, "Boca Juniors", "Cruzeiro", "2026-05-19 21:30:00 UTC", "Estadio La Bombonera", "Buenos Aires", "Group D"],
  [1402, "Universidad Católica", "Barcelona SC", "2026-05-21 21:30:00 UTC", "Estadio Claro Arena", "Santiago", "Group D"],
  [1403, "Cruzeiro", "Universidad Católica", "2026-05-27 21:30:00 UTC", "Mineirão", "Belo Horizonte", "Group D"],
  [1404, "Barcelona SC", "Boca Juniors", "2026-05-27 23:00:00 UTC", "Estadio Monumental Banco Pichincha", "Guayaquil", "Group D"],

  # Grupo E
  [1501, "Peñarol", "Atlético Nacional", "2026-05-20 21:30:00 UTC", "Estadio Campeón del Siglo", "Montevideo", "Group E"],
  [1502, "Vélez Sarsfield", "Olimpia", "2026-05-20 23:00:00 UTC", "Estadio José Amalfitani", "Buenos Aires", "Group E"],
  [1503, "Peñarol", "Vélez Sarsfield", "2026-05-27 21:30:00 UTC", "Estadio Campeón del Siglo", "Montevideo", "Group E"],
  [1504, "Atlético Nacional", "Olimpia", "2026-05-27 21:30:00 UTC", "Estadio Atanasio Girardot", "Medellín", "Group E"],

  # Grupo F
  [1601, "Palmeiras", "Cerro Porteño", "2026-05-20 21:30:00 UTC", "Allianz Parque", "São Paulo", "Group F"],
  [1602, "Junior", "Sporting Cristal", "2026-05-20 23:00:00 UTC", "Estadio Olímpico Jaime Morón León", "Cartagena", "Group F"],
  [1603, "Palmeiras", "Junior", "2026-05-28 21:30:00 UTC", "Allianz Parque", "São Paulo", "Group F"],
  [1604, "Cerro Porteño", "Sporting Cristal", "2026-05-28 21:30:00 UTC", "Estadio General Pablo Rojas", "Asunción", "Group F"],

  # Grupo G
  [1701, "Always Ready", "Mirassol", "2026-05-19 21:30:00 UTC", "Estadio Municipal de El Alto", "El Alto", "Group G"],
  [1702, "LDU Quito", "Lanús", "2026-05-20 21:30:00 UTC", "Estadio Rodrigo Paz Delgado", "Quito", "Group G"],
  [1703, "LDU Quito", "Always Ready", "2026-05-26 21:30:00 UTC", "Estadio Rodrigo Paz Delgado", "Quito", "Group G"],
  [1704, "Lanús", "Mirassol", "2026-05-26 21:30:00 UTC", "Estadio Ciudad de Lanús", "Lanús", "Group G"],

  # Grupo H
  [1801, "Rosario Central", "Universidad Central", "2026-05-19 21:30:00 UTC", "Estadio Gigante de Arroyito", "Rosario", "Group H"],
  [1802, "Independiente del Valle", "Libertad", "2026-05-19 23:00:00 UTC", "Estadio Banco Guayaquil", "Quito", "Group H"],
  [1803, "Independiente del Valle", "Rosario Central", "2026-05-27 21:30:00 UTC", "Estadio Banco Guayaquil", "Quito", "Group H"],
  [1804, "Libertad", "Universidad Central", "2026-05-27 21:30:00 UTC", "Estadio Defensores del Chaco", "Asunción", "Group H"]
]


libertadores_games.each do |number, home, away, starts_at, stadium, city, stage|
  create_game!(
    competition: libertadores,
    number: number,
    home: home,
    away: away,
    starts_at: starts_at,
    stadium: stadium,
    city: city,
    stage: stage
  )
end



def seed_static_games!(competition_slug:, competition_name:, games:)
  competition = Competition.find_or_create_by!(slug: competition_slug) do |c|
    c.name = competition_name
  end

  games.each do |number, starts_at, home, away, stadium, city, stage|
    Game.find_or_initialize_by(
      competition: competition,
      fifa_match_number: number
    ).tap do |game|
      game.home_team = team_for(home)
      game.away_team = team_for(away)
      game.starts_at = Time.zone.parse(starts_at)
      game.stadium = stadium
      game.city = city
      game.stage = stage
      game.status = "scheduled"
      game.home_score = nil
      game.away_score = nil
      game.minute = nil
      game.save!
    end
  end
end

liga_argentina_games = [
  [3001, "2026-05-09 19:30:00 UTC", "Talleres", "Belgrano", "Estadio Mario Alberto Kempes", "Córdoba", "Octavos de final"],
  [3002, "2026-05-09 22:00:00 UTC", "Boca Juniors", "Huracán", "La Bombonera", "Buenos Aires", "Octavos de final"],
  [3003, "2026-05-10 00:30:00 UTC", "Argentinos Juniors", "Lanús", "Estadio Diego Armando Maradona", "Buenos Aires", "Octavos de final"],
  [3004, "2026-05-10 00:30:00 UTC", "Independiente Rivadavia", "Unión de Santa Fe", "Estadio Bautista Gargantini", "Mendoza", "Octavos de final"],
  [3005, "2026-05-10 18:00:00 UTC", "Rosario Central", "Independiente", "Gigante de Arroyito", "Rosario", "Octavos de final"],
  [3006, "2026-05-10 20:00:00 UTC", "Estudiantes", "Racing Club", "Estadio UNO", "La Plata", "Octavos de final"],
  [3007, "2026-05-10 22:00:00 UTC", "River Plate", "San Lorenzo", "Monumental", "Buenos Aires", "Octavos de final"],
  [3008, "2026-05-11 00:30:00 UTC", "Vélez Sarsfield", "Gimnasia La Plata", "José Amalfitani", "Buenos Aires", "Octavos de final"]
]

seed_static_games!(
  competition_slug: "liga-argentina",
  competition_name: "Liga Argentina",
  games: liga_argentina_games
)

