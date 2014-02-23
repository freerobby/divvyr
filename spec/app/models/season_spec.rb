require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'app', 'models', 'season'))

describe Season do
  describe '#initialize' do
    it 'initializes games, buyers and entries' do
      obj = Season.new
      obj.instance_variable_get(:@games).should == []
      obj.instance_variable_get(:@buyers).should == []
      obj.instance_variable_get(:@entries).should == []
    end
  end
end
