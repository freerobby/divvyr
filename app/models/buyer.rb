class Buyer
  attr_accessor :name, :games_priority, :multiple_slots_per_game
  
  def initialize(name, number_of_games, multiple_slots_per_game)
    @name = name
    @number_of_games = number_of_games.to_i
    @games_priority = []
    @multiple_slots_per_game = multiple_slots_per_game
  end
  
  def number_of_games
    @number_of_games.to_i
  end
  def number_of_games=(val)
    @number_of_games = val.to_i
  end
  
  def to_s
    "#{name} (#{number_of_games} game#{'s' if number_of_games != 1})"
  end
end