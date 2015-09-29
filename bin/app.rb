#!/usr/bin/ruby

require './app/boot.rb'

require 'csv'
require 'highline/import'

require './app/lib/mlb_importer'
require './app/lib/nba_importer'

require './app/menus/import_mlb_games_menu'
require './app/menus/import_nba_games_menu'

require './app/models/buyer'
require './app/models/entry'
require './app/models/game'
require './app/models/season'

say "Welcome to <%= color('divvyr', RED) %>."

@season = Season.new

def get_season_name
  puts 'Enter season name:'
  @season_name = gets.strip!
end
def require_season_name
  get_season_name if @season_name.nil?
end

loop do
  choose do |menu|
    menu.index = :letter
    menu.index_suffix = ') '
    
    menu.prompt = "Choose an option: "
    
    menu.choice 'Load season' do
      get_season_name
      @season = Season.load_from_file(@season_name)
    end
    menu.choice 'Save season' do
      require_season_name
      @season.save_to_file(@season_name)
    end

    menu.choice 'Import MLB games' do
      ImportMlbGamesMenu.invoke(@season)
    end

    menu.choice 'Import NBA games' do
      ImportNbaGamesMenu.invoke(@season)
    end
    
    menu.choice 'import CSV games' do
      path = ask("Where's your spreadsheet: ")
      CSV.foreach(path, headers: true) do |line|
        id = line.fields[0]
        data = []
        for datum_index in 1..(line.fields.size - 1) do
          data << line.fields[datum_index]
        end
        @season.games << Game.new(id, data)
      end
      say "Import complete. Season now has #{@season.games.size} games."
    end
    if !@season.games.empty? && !@season.buyers.empty?
      menu.choice 'Create buyer spreadsheets' do
        require_season_name

        @season.buyers.each do |buyer|
          name = buyer.name.gsub(' ', '-').downcase
          filename = "./spreadsheets/#{@season_name}-#{name}.csv"
          CSV.open(filename, 'wb') do |csv|
            @season.games.each do |game|
              csv << [game.identifier] + game.data
            end
          end
          say "Generated spreadsheet: #{filename}."
        end
      end

      menu.choice 'Import buyer choices' do
        @season.buyers.each do |buyer|
          name = buyer.name.gsub(' ', '-').downcase
          filename = "./spreadsheets/#{@season_name}-#{name}.csv"
          buyer.games_priority = []
          CSV.foreach(filename, headers: false) do |csv|
            buyer.games_priority << csv[0]
          end
          say "Imported spreadsheet: #{filename}. Buyer prioritized #{buyer.games_priority.count} games."
        end
      end
    end
    if !@season.games.empty?
      menu.choice 'view games' do
        say("Displaying Games")
        @season.list_games
      end
      menu.choice 'delete game' do
        selected_game = nil
        choose do |game|
          game.index = :letter
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
          buyer.index = :letter
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
          buyer.index = :letter
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
          buyer.index = :letter
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
          selected_buyer.games_priority = [] if selected_buyer.games_priority.size == @season.games.size
          selected_game = 1
          while selected_buyer.games_priority.size < @season.games.size && selected_game != nil do
            selected_game = nil
            choose do |game|
              game.index = :letter
              game.index_suffix = ') '
              game.prompt = "Enter choice ##{selected_buyer.games_priority.size + 1}: "

              game.choice 'enter CSV list' do
                puts "Enter games: "
                csvgames = gets
                ids = csvgames.split(',')
                ids.each {|id| id.strip!}
                ids.each do |id|
                  if @season.game_by_identifier(id)
                    selected_buyer.games_priority << @season.game_by_identifier(id).identifier
                  else
                    puts "Warning: game not found for identifier: #{id}"
                  end
                end
                selected_game = nil
              end

              @season.list_games_without_buyer_preference(selected_buyer).each do |game_remaining|
                game.choice game_remaining do
                  selected_game = game_remaining
                end
              end
              game.choice 'finish later' do
                selected_game = nil
              end
            end
            if !selected_game.nil?
              selected_buyer.games_priority << selected_game.identifier
            end
          end
        end
      end
      
      menu.choice 'view all buyer game preferences' do
        @season.buyers.each do |buyer|
          puts "#{buyer.name}: #{buyer.games_priority.join(', ')}"
        end
      end
      
      menu.choice 'view single buyer game preferences' do
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
      menu.choice "Set number of draft rounds (currently #{@season.num_draft_rounds})" do
        old_num = @season.num_draft_rounds
        @season.num_draft_rounds = ask("Number of draft rounds: ", Integer)
        if old_num != @season.num_draft_rounds
          @season.generate_entries
          @season.randomize_entries
        end
      end
      menu.choice 'prepare draft' do
        @season.buyers.each do |buyer|
          puts "#{buyer.name} gets #{@season.num_draft_entries_for(buyer)} entr#{@season.num_draft_entries_for(buyer) == 1 ? 'y' : 'ies'}"
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
        menu.choice 'remove inactive draft entries' do
          say "Starting with #{@season.entries.size} entries."
          @season.entries.each {|e| @season.entries.delete(e) unless e.round_data.include?('P')}
          say "Finished with #{@season.entries.size} entries remaining."
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
        menu.choice 'validate draft entries' do
          puts "Season has #{@season.games.size} games"
          count = 0
          @season.entries.each do |entry|
            entry.round_data.each {|l| count +=1 if l == 'P'}
          end
          puts "Entries will draft #{count} games"
          if @season.games.size == count
            say "Current state of entries is <%= color('valid', GREEN) %>."
          else
            say "Current state of entries is <%= color('invalid', RED) %>."
          end
        end
        
        menu.choice 'run draft' do
          say "Running draft..."
          buyer_games = {}
          @season.buyers.each {|b| buyer_games[b.name] = []}
          
          num_rounds = @season.entries.first.round_data.size
          remaining_game_ids = []
          @season.games.each {|g| remaining_game_ids << g.identifier}
          
          for round_index in 1..num_rounds do
            break if remaining_game_ids.empty?
            say "Beginning draft round #{round_index}"
            counter = 1
            if round_index % 2 == 1
              @season.entries.each do |entry|
                buyer = @season.buyer_by_name(entry.buyer_name)
              
                if entry.round_data[round_index - 1] == 'P'
                  buyer.games_priority.each do |game_id|
                    if !remaining_game_ids.index(game_id).nil?
                      say "Round #{round_index}, pick #{counter} belongs to #{buyer.name} (choice ##{buyer.games_priority.index(game_id)+1}): #{@season.game_by_identifier(game_id)}\n"
                      buyer_games[buyer.name] << game_id
                      remaining_game_ids.delete(game_id)
                      break
                    end
                  end
                
                  counter += 1
                else
                  say "Skipping #{buyer}; no pick this round."
                end
              end
            else
              @season.entries.reverse_each do |entry|
                buyer = @season.buyer_by_name(entry.buyer_name)
              
                if entry.round_data[round_index - 1] == 'P'
                  buyer.games_priority.each do |game_id|
                    if !remaining_game_ids.index(game_id).nil?
                      say "Round #{round_index}, pick #{counter} belongs to #{buyer.name} (choice ##{buyer.games_priority.index(game_id)+1}): #{@season.game_by_identifier(game_id)}\n"
                      buyer_games[buyer.name] << game_id
                      remaining_game_ids.delete(game_id)
                      break
                    end
                  end
                
                  counter += 1
                else
                  say "Skipping #{buyer}; no pick this round."
                end
              end
            end
          end
          say "Draft Results:"
          @season.buyers.each do |buyer|
            say "#{buyer}:"
            buyer_games[buyer.name].sort{|a, b| a.to_i <=> b.to_i}.each do |g|
              say "\t#{@season.game_by_identifier(g)} (choice ##{buyer.games_priority.index(g)+1})"
            end
          end
        end
      end
    end
    
    menu.choice 'exit' do
      if agree("Save before exit?: ")
        require_season_name
        @season.save_to_file(@season_name)
      end
      exit
    end
  end
end