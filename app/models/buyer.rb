class Buyer
  attr_accessor :name, :games_priority
  
  def initialize(name, number_of_games)
    @name = name
    @number_of_games = number_of_games.to_i
    @games_priority = []
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