require 'highline/import'

require './app/lib/nba_importer'

class ImportNbaGamesMenu
  def self.invoke(season)
    team_id = nil

    choose do |menu|
      menu.index = :letter
      menu.index_suffix = ') '
      menu.prompt = 'What team\'s schedule would you like to import?'
      menu.choice 'Celtics' do
        team_id = 'celtics'
      end
    end

    NbaImporter.new.get_valid_games(team_id).each {|g| season.games << g}
    say "Import complete. Season now has #{season.games.size} games."
  end
end
