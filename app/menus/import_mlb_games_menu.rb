require 'highline/import'

class ImportMlbGamesMenu
  def self.invoke(season)
    say 'Team IDs are as follows:'
    MlbImporter::TEAM_IDS.each do |team, id|
      say "#{team}: #{id}"
    end
    id = ask("Enter team ID: ")
    year = ask("Enter season year to fetch: ")
    MlbImporter.new.get_valid_games(id, year).each {|g| season.games << g}
    say "Import complete. Season now has #{season.games.size} games."
  end
end
