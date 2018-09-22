require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'app', 'models', 'entry'))

describe Entry do
  before do
    @game = Entry.new('Joe Smith', ['P', 'N', 'P'])
  end
  describe '#to_s' do
    it 'includes name of buyer' do
      expect(@game.to_s).to include('Joe Smith')
    end
    it 'includes comma-separated round data' do
      expect(@game.to_s).to include('P, N, P')
    end
  end
end
