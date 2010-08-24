require 'yaml'

class Season
  attr_accessor :games, :buyers
  
  def initialize
    @games = []
    @buyers = []
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
end