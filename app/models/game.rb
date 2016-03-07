class Game
  attr_accessor :identifier, :data, :available
  
  def initialize(identifier, data, available = 1)
    @identifier = identifier
    @data = data
    @available = available
  end
  
  def to_s
    str = "id: #{identifier}"
    @data.each do |d|
      str += " | #{d}"
    end
    str
  end
end