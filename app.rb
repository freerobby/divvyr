require 'boot.rb'

require 'highline/import'

say "Welcome to <%= color('divvyr', RED) %>."

@games = []
@buyers = []

loop do
  choose do |menu|
    menu.index = :letter
    menu.index_suffix = ') '
    
    menu.prompt = "Choose an option:"
    
    menu.choice 'import games' do
    end
    if !@games.empty?
      menu.choice 'view games' do
      end
      menu.choice 'delete games' do
      end
    end
    
    menu.choice 'add a buyer' do
    end
    if !@buyers.empty?
      menu.choice 'edit a buyer' do
      end
      menu.choice 'remove a buyer' do
      end
    end
    
    if !@games.empty? && !@buyers.empty?
      menu.choice 'run draft' do
      end
    end
    
    menu.choice 'exit' do
      exit
    end
  end
end