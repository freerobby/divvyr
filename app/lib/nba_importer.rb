require 'csv'
require 'open-uri'
require 'icalendar'

require './app/models/game'

class NbaImporter
  def get_valid_games(team_name)
    parsed_games = get_schedule(team_name)
    games = []
    last_game = 0
    parsed_games.each_with_index do |parsed_game|
      if parsed_game[:location] == 'Boston' && parsed_game[:time] >= Time.new(2015, 10, 28)
        games << Game.new("#{last_game + 1}", [parsed_game[:time], parsed_game[:description]])
        last_game += 1
      end
    end
    games
  end

  private
  def get_schedule(team_name)
    data = Icalendar.parse(get_ics_schedule(team_name)).first
    games = []
    data.events.each do |event|
      games << {
        time: Time.parse(event.dtstart.to_s),
        description: "#{event.summary}",
        location: "#{event.location}"
      }
    end

    games.sort{|a,b| a[:time] <=> b[:time]}
  end

  def get_ics_schedule(team_name)
    open(lookup_url(team_name)) {|f| f.read}
  end

  def lookup_url(team_name)
    "https://stanza.co/api/schedules/espn-nba/bos/#{team_name}.ics"
  end
end
