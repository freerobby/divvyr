require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'app', 'models', 'buyer'))

describe Buyer do
  before do
    @buyer = Buyer.new('Joe Smith', 5)
  end
  describe '#number_of_games' do
    it 'returns number of games' do
      @buyer.number_of_games.should == 5
    end
  end
  describe '#number_of_games=' do
    it 'sets number of games' do
      @buyer.number_of_games = 3
      @buyer.number_of_games.should == 3
    end
  end
  describe '#to_s' do
    it 'includes name of buyer' do
      @buyer.to_s.should include('Joe Smith')
    end
    it 'includes number of games' do
      @buyer.to_s.should include('5')
    end
  end
end
