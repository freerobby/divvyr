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
      if buyer.multiple_slots_per_game
        true
      else
        if buyer_games[buyer.name].include?(game)
          false
        else
          true
        end
      end
    end
  end
end
