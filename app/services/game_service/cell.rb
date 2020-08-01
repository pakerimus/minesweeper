module GameService
  class Cell
    attr_accessor :game, :cell, :options

    def initialize(game, cell, **options)
      @game = game
      @cell = cell
      @options = options
    end

    def execute_action!
      send(options[:action_name])
      [true, 'ok']
    rescue StandardError => e
      [false, e.message]
    end

    def cycle_mark
      cell.cycle_mark!
    end

    def clear
      return unless cell.can_be_cleared?

      return explosion if cell.bomb?

      if cell.without_adjacent_bombs?
        clear_adjacent_cells
      else
        cell.clear!
      end

      game_svc.calculate_remaining_plays
    end

    private
      def explosion
        game_svc.explode
      end

      def clear_adjacent_cells
        # adjacent cells include own
        cell.adjacent_cells.map(&:clear!)
      end

      def game_svc
        @_game_svc = GameService::Game.new(game)
      end
  end
end
