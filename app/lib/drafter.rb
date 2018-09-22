require_relative '../models/buyer'
require_relative '../models/entry'
require_relative '../models/game'
require_relative '../models/season'

class Drafter
  class << self
    def is_game_remaining?(remaining_games, game)
      !remaining_games.index(game).nil?
    end

    def buyer_wants_game?(buyer, buyer_games, game)
      if multislot_games(buyer_games[buyer.name]).include?(game)
        # If the buyer already has this multislot game, they are willing to spend more slots on it.
        true
      elsif buyer.max_multislot_games > multislot_games(buyer_games[buyer.name]).count
        # If the buyer wants more multislot games, then they want any game.
        true
      else
        # If the buyer does not want more multislot games, pass on this game iff they already have it.
        if buyer_games[buyer.name].include?(game)
          false
        else
          true
        end
      end
    end

    private
    def multislot_games(games)
      games.select{|g| games.count(g) > 1}.uniq
    end
  end
end
