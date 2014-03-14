require 'highline/import'
require 'yaml'

class Season
  attr_accessor :games, :buyers, :entries, :num_draft_rounds
  
  def initialize
    @games = []
    @buyers = []
    @entries = []
    @num_draft_rounds = 5
  end

  def self.load_from_file(filename)
    data = File.open("./seasons/#{filename}.yml", "r") {|file| YAML::load(file)}
    season = Season.new
    season.buyers = data[:buyers]
    season.entries = data[:entries]
    season.games = data[:games]
    season.num_draft_rounds = data[:num_draft_rounds] if data[:num_draft_rounds]
    say "Loaded #{@season_name}.yml with #{season.games.size} games, #{season.buyers.size} buyers and #{season.num_draft_rounds} draft rounds."
    season
  end
  def save_to_file(filename)
    File.open("./seasons/#{filename}.yml", "w") {|file| YAML.dump({
      buyers: self.buyers,
      entries: self.entries,
      games: self.games,
      num_draft_rounds: self.num_draft_rounds
    }, file)}
    say "Season saved to #{filename}.yml."
  end
  
  def list_games
    games.each {|g| puts g}
  end
  
  def list_games_without_buyer_preference(buyer)
    games_remaining = []
    games.each do |g|
      games_remaining << g if !buyer.games_priority.include?(g.identifier)
    end
    games_remaining
  end
  
  def list_buyers
    buyers.each {|b| puts b}
    num_games = 0
    buyers.each {|b| num_games += b.number_of_games}
    puts "#{buyers.size} buyer#{'s' if buyers.size != 1} with rights to #{games.size} game#{'s' if games.size != 1}"
  end
  
  def num_draft_entries_for(buyer)
    num_entries = buyer.number_of_games / num_draft_rounds
    num_entries += 1 if buyer.number_of_games % num_draft_rounds > 0
    num_entries
  end
  
  def create_draft_entries_for(buyer)
    num_entries = num_draft_entries_for(buyer)
    for this_entry_index in 1..num_entries do
      extras = buyer.number_of_games % num_draft_rounds
      if this_entry_index < num_entries || extras == 0
        this_entry_data = []
        num_draft_rounds.times {this_entry_data << 'P'}
        entries << Entry.new(buyer.name, this_entry_data)
      else # Partial entry
        this_entry_data = []
        (num_draft_rounds - extras).times {this_entry_data << 'N'}
        extras.times {this_entry_data << 'P'}
        entries << Entry.new(buyer.name, this_entry_data)
      end
    end
  end
  
  def generate_entries
    self.entries = []
    buyers.each do |b|
      create_draft_entries_for(b)
    end
  end
  def randomize_entries
    entries.shuffle!
  end
  
  def game_by_identifier(id)
    game = nil
    games.each do |g|
      game = g if g.identifier.strip.to_s == id.strip.to_s
    end
    game
  end
  def buyer_by_name(buyer_name)
    buyer = nil
    buyers.each do |b|
      buyer = b if b.name == buyer_name
    end
    buyer
  end
end