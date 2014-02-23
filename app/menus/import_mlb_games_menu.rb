require 'highline/import'

require './app/lib/mlb_importer'

class ImportMlbGamesMenu
  def self.invoke(season)
    team_id = nil

    choose do |menu|
      menu.index = :letter
      menu.index_suffix = ') '
      menu.prompt = 'What team\'s schedule would you like to import?'
      MlbImporter::TEAM_IDS.sort{|a,b|a<=>b}.each do |team, id|
        menu.choice team do
          team_id = id
        end
      end
    end

    year = ask("Enter season year to fetch [e.g. '2014]: ")
    MlbImporter.new.get_valid_games(team_id, year).each {|g| season.games << g}
    say "Import complete. Season now has #{season.games.size} games."
  end
end
