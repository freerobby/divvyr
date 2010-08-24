class Entry
  attr_accessor :buyer_name, :round_data
  
  def initialize(buyer_name, round_data)
    @buyer_name = buyer_name
    @round_data = round_data
  end
  
  def to_s
    "#{buyer_name} (#{round_data.join(', ')})"
  end
end