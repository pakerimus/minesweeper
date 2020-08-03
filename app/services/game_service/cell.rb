module GameService
  class Cell
    attr_accessor :game, :cell, :options

    def initialize(game, cell, **options)
      @game = game
      @cell = cell
      @options = options
    end

    def execute_action!
      validate_action!
      send(options[:cell_action].to_sym)
      [true, 'ok']
    rescue StandardError => e
      [false, e.message]
    end

    def validate_action!
      raise 'Invalid action' unless self.respond_to?(options[:cell_action].to_sym)
      raise 'Not allowed: Game has finished' if game.finished?

      raise 'Not allowed: cell cannot be cleared' if options[:cell_action] == "clear" && !cell.can_be_cleared?
      raise 'Not allowed: cell is cleared' if options[:cell_action] == "cycle_mark" && cell.cleared?
    end

    def cycle_mark
      cell.cycle_mark!
    end

    def clear
      game_svc.start(cell) if game.pending?

      clear_cell(cell)

      game_svc.calculate_remaining_plays
    end

    private
      def explosion
        game_svc.explode
      end

      def clear_cell(a_cell)
        return unless a_cell.can_be_cleared?
        return explosion if a_cell.bomb?

        if a_cell.without_adjacent_bombs?
          clear_adjacent_cells(a_cell)
        else
          a_cell.clear!
        end
      end

      def clear_adjacent_cells(a_cell)
        a_cell.adjacent_cells.each do |adjacent_cell|
          clear_cell(adjacent_cell)
        end
      end

      def game_svc
        @_game_svc = GameService::Game.new(game)
      end
  end
end
