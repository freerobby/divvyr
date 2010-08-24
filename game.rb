class Game
  attr_accessor :identifier, :data
  
  def initialize(identifier, data)
    @identifier = identifier
    @data = data
  end
  
  def to_s
    str = "id: #{identifier}"
    @data.each do |d|
      str += " | #{d}"
    end
    str
  end
end