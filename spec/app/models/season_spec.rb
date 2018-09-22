require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'app', 'models', 'season'))

describe Season do
  describe '#initialize' do
    it 'initializes games, buyers and entries' do
      obj = Season.new
      expect(obj.instance_variable_get(:@games)).to eql([])
      expect(obj.instance_variable_get(:@buyers)).to eql([])
      expect(obj.instance_variable_get(:@entries)).to eql([])
    end
  end
end
