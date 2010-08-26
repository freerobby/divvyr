require 'boot.rb'

require 'faster_csv'
require 'highline/import'

require 'buyer'
require 'entry'
require 'game'
require 'season'

say "Welcome to <%= color('divvyr', RED) %>."

@season = Season.new

loop do
  choose do |menu|
    menu.index = :letter
    menu.index_suffix = ') '
    
    menu.prompt = "Choose an option: "
    
    menu.choice 'load season' do
      @season = File.open(".divvyr_season.yaml", "r") {|file| YAML::load(file)}
      say "Loaded season with #{@season.games.size} games and #{@season.buyers.size} buyers."
    end
    menu.choice 'save season' do
      File.open(".divvyr_season.yaml", "w") {|file| YAML.dump(@season, file)}
      say "Season saved."
    end
    
    menu.choice 'import games' do
      path = ask("Where's your spreadsheet: ")
      FasterCSV.foreach(path, :headers => true) do |line|
        id = line.fields[0]
        data = []
        for datum_index in 1..(line.fields.size - 1) do
          data << line.fields[datum_index]
        end
        @season.games << Game.new(id, data)
      end
      say "Import complete (season now has #{@season.games.size} games)"
    end
    if !@season.games.empty?
      menu.choice 'view games' do
        say("Displaying Games")
        @season.list_games
      end
      menu.choice 'delete game' do
        selected_game = nil
        choose do |game|
          game.index = :number
          game.index_suffix = ') '
          game.prompt = 'Which game would you like to delete?'
          game.choice 'cancel' do
            selected_game = nil
          end
          @season.games.each do |season_game|
            game.choice season_game do
              selected_game = season_game
            end
          end
        end
        if !selected_game.nil?
          @season.games.delete(selected_game)
        end
      end
    end
    
    menu.choice 'add a buyer' do
      name = ask("Buyer name: ")
      num_games = ask("Number of games: ", Integer)
      @season.buyers << Buyer.new(name, num_games)
    end
    if !@season.buyers.empty?
      menu.choice 'list buyers' do
        say "Listing buyers"
        @season.list_buyers
      end
      menu.choice 'edit a buyer' do
        selected_buyer = nil
        choose do |buyer|
          buyer.index = :number
          buyer.index_suffix = ') '
          buyer.prompt = 'Which buyer would you like to edit?'
          buyer.choice 'cancel' do
            selected_buyer = nil
          end
          @season.buyers.each do |season_buyer|
            buyer.choice season_buyer do
              selected_buyer = season_buyer
            end
          end
        end
        if !selected_buyer.nil?
          puts "Editing #{selected_buyer}..."
          new_name = ask("New name: ")
          new_num_games = ask("New number of games: ")
          selected_buyer.name = new_name unless new_name.length < 1
          selected_buyer.number_of_games = new_num_games unless new_num_games.length < 1
        end
      end
      menu.choice 'remove a buyer' do
        selected_buyer = nil
        choose do |buyer|
          buyer.index = :number
          buyer.index_suffix = ') '
          buyer.prompt = 'Which buyer would you like to remove?'
          buyer.choice 'cancel' do
            selected_game = nil
          end
          @season.buyers.each do |season_buyer|
            buyer.choice season_buyer do
              selected_buyer = season_buyer
            end
          end
        end
        if !selected_buyer.nil?
          @season.buyers.delete(selected_buyer)
        end
      end
      menu.choice 'input buyer game preferences' do
        selected_buyer = nil
        choose do |buyer|
          buyer.index = :number
          buyer.index_suffix = ') '
          buyer.prompt = 'Buyer to enter preferences for: '
          buyer.choice 'cancel' do
            selected_buyer = nil
          end
          @season.buyers.each do |season_buyer|
            buyer.choice season_buyer do
              selected_buyer = season_buyer
            end
          end
        end
        if !selected_buyer.nil?
          selected_game = 1
          while selected_buyer.games_priority.size < @season.games.size && selected_game != nil do
            selected_game = nil
            choose do |game|
              game.index = :letter
              game.index_suffix = ') '
              game.prompt = "Enter choice ##{selected_buyer.games_priority.size + 1}: "
              game.choice 'finish later' do
                selected_game = nil
              end
              @season.list_games_without_buyer_preference(selected_buyer).each do |game_remaining|
                game.choice game_remaining do
                  selected_game = game_remaining
                end
              end
            end
            if !selected_game.nil?
              selected_buyer.games_priority << selected_game.identifier
            end
          end
        end
      end
      
      menu.choice 'view buyer game preferences' do
        selected_buyer = 1
        while !selected_buyer.nil?
          choose do |buyer|
            buyer.index = :letter
            buyer.index_suffix = ') '
            buyer.prompt = "Player's game selections to view: "
            buyer.choice 'go back' do
              selected_buyer = nil
            end
            @season.buyers.each do |season_buyer|
              buyer.choice season_buyer do
                selected_buyer = season_buyer
              end
            end
          end
          if !selected_buyer.nil?
            puts "Displaying choices for #{selected_buyer}:"
            for index in 1..@season.games.size do
              puts "#{index}. #{@season.game_by_identifier(selected_buyer.games_priority[index - 1])}"
            end
          end
        end
      end
    end
    
    if !@season.games.empty? && !@season.buyers.empty?
      menu.choice 'prepare draft' do
        @season.buyers.each do |buyer|
          puts "#{buyer.name} gets #{@season.num_draft_entries_for(buyer, 5)} entr#{@season.num_draft_entries_for(buyer, 5) == 1 ? 'y' : 'ies'}"
        end
        @season.generate_entries
        puts "Entries are as follows:"
        counter = 1
        @season.entries.each do |e|
          puts "#{counter}. #{e}"
          counter += 1
        end
        puts "Randomized entries:"
        @season.randomize_entries
        counter = 1
        @season.entries.each do |e|
          puts "#{counter}. #{e}"
          counter += 1
        end
      end
      
      if !@season.entries.empty?
        menu.choice 'view draft entries in order' do
          counter = 1
          @season.entries.each do |e|
            puts "#{counter}. #{e}"
            counter += 1
          end
        end
        menu.choice 'edit draft entries' do
          selected_entry = 1
          while !selected_entry.nil?
            choose do |draft_entry|
              draft_entry.index = :letter
              draft_entry.index_suffix = ') '
              draft_entry.prompt = 'Which draft entry to modfy?: '
              
              draft_entry.choice 'go back' do
                selected_entry = nil
              end
              @season.entries.each do |entry|
                draft_entry.choice entry do
                  selected_entry = entry
                end
              end
            end
            if !selected_entry.nil?
              length = selected_entry.round_data.size
              puts "Current entry: #{selected_entry}"
              new_entry = []
              for i in 1..length do
                new_entry.push(ask("Entry value at position #{i}: "))
              end
              selected_entry.round_data = new_entry
            end
          end
        end
        menu.choice 'random order draft entries' do
          puts "Randomized entries:"
          @season.randomize_entries
          counter = 1
          @season.entries.each do |e|
            puts "#{counter}. #{e}"
            counter += 1
          end
        end
        menu.choice 'manual order draft entries' do
          new_entries = []
          while @season.entries.size > 0
            choose do |next_entry|
              next_entry.index = :letter
              next_entry.index_suffix = ') '
              next_entry.prompt = 'Choose next entry: '
              
              @season.entries.each do |entry|
                next_entry.choice entry do
                  new_entries.push(entry)
                  @season.entries.delete(entry)
                end
              end
            end
          end
          @season.entries = new_entries
        end
      end
    end
    
    menu.choice 'exit' do
      File.open(".divvyr_season.yaml", "w") {|file| YAML.dump(@season, file)} if agree("Save before exit?: ")
      exit
    end
  end
end