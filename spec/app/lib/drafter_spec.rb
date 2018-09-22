require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'app', 'lib', 'drafter'))

describe Drafter do
  describe '#multislot_games' do
    it 'returns list of games that are already multislot-chosen' do
      expect(Drafter.send(:multislot_games, [1, 2, 3, 3, 4, 4, 5, 6, 6, 6, 7, 7, 7, 7, 8, 9])).to eql([3, 4, 6, 7])
    end
  end
end
