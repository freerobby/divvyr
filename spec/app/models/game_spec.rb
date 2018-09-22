require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'app', 'models', 'game'))

describe Game do
  before do
    @game = Game.new('Red Sox', ['P', 35])
  end
  describe '#to_s' do
    it 'includes identifier' do
      expect(@game.to_s).to include('Red Sox')
    end
    it 'includes pipe-separated data' do
      expect(@game.to_s).to include('P | 35')
    end
  end
end
