require 'csv'
require 'open-uri'

require './app/models/game'

class MlbImporter
  TEAM_IDS = {
    # American League
    'Baltimore Orioles' => 110,
    'Boston Red Sox' => 111,
    'Chicago White Sox' => 145,
    'Cleveland Indians' => 114,
    'Detroit Tigers' => 116,
    'Houston Astros' => 117,
    'Kansas City Royals' => 118,
    'Los Angeles Angels' => 108,
    'Minnesota Twins' => 142,
    'New York Yankees' => 147,
    'Oakland Athletics' => 133,
    'Seattle Mariners' => 136,
    'Tampa Bay Rays' => 139,
    'Texas Rangers' => 140,
    'Toronto Blue Jays' => 141,

    # National League
    'Arizona Diamondbacks' => 109,
    'Atlanta Braves' => 144,
    'Chicago Cubs' => 112,
    'Cincinnati Reds' => 113,
    'Colorado Rockies' => 115,
    'Los Angeles Dodgers' => 119,
    'Miami Marlins' => 146,
    'Milwaukee Brewers' => 158,
    'New York Mets' => 121,
    'Philadelphia Phillies' => 143,
    'Pittsburgh Pirates' => 134,
    'San Diego Padres' => 135,
    'San Francisco Giants' => 137,
    'St. Louis Cardinals' => 138,
    'Washington Nationals' => 120,
  }

  def get_valid_games(team_id, year)
    parsed_games = get_schedule(team_id, year)
    games = []
    last_game = 0
    parsed_games.each_with_index do |parsed_game|
      if parsed_game[:location] == 'Fenway Park' && !parsed_game[:description].include?('All-Stars')
        games << Game.new("HG#{last_game + 1}", [parsed_game[:time], parsed_game[:description]])
        last_game += 1
      end
    end
    games
  end

  private
  COL_START_DATE = 0
  COL_START_TIME = 1
  COL_SUBJECT = 3
  COL_LOCATION = 4
  def get_schedule(team_id, year)
    data = get_csv_schedule(team_id, year)
    games = []
    CSV.parse(data, headers: true).each do |row|
      games << {
        time: "#{row[COL_START_DATE]} #{row[COL_START_TIME]}",
        description: row[COL_SUBJECT],
        location: row[COL_LOCATION]
      }
    end
    games
  end

  def get_csv_schedule(team_id, year)
    open(lookup_url(team_id, year)) {|f| f.read}
  end

  def lookup_url(team_id, year)
    "http://mlb.mlb.com/soa/ical/schedule.csv?home_team_id=#{team_id}&season=#{year}"
  end
end
