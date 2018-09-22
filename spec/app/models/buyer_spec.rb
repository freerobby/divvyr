require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'app', 'models', 'buyer'))

describe Buyer do
  before do
    @buyer = Buyer.new('Joe Smith', 5, 0)
  end
  describe '#number_of_games' do
    it 'returns number of games' do
      expect(@buyer.number_of_games).to eql(5)
    end
  end
  describe '#number_of_games=' do
    it 'sets number of games' do
      @buyer.number_of_games = 3
      expect(@buyer.number_of_games).to eql(3)
    end
  end
  describe '#to_s' do
    it 'includes name of buyer' do
      expect(@buyer.to_s).to include('Joe Smith')
    end
    it 'includes number of games' do
      expect(@buyer.to_s).to include('5')
    end
  end
end
