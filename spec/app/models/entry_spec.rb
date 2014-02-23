require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'app', 'models', 'entry'))

describe Entry do
  before do
    @game = Entry.new('Joe Smith', ['P', 'N', 'P'])
  end
  describe '#to_s' do
    it 'includes name of buyer' do
      @game.to_s.should include('Joe Smith')
    end
    it 'includes comma-separated round data' do
      @game.to_s.should include('P, N, P')
    end
  end
end
