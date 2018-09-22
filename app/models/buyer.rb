class Buyer
  attr_accessor :name, :games_priority, :multiple_slots_per_game, :max_multislot_games
  
  def initialize(name, number_of_games, max_multislot_games)
    @name = name
    @number_of_games = number_of_games.to_i
    @games_priority = []
    @max_multislot_games = max_multislot_games.to_i
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