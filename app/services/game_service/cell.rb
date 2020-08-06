module GameService
  class Cell
    attr_accessor :game, :cell, :options

    class InvalidCellActionException < StandardError; end

    def initialize(game, cell, **options)
      @game = game
      @cell = cell
      @options = options
      options["cell_action"] ||= ''
      @cell_callback = nil
    end

    def execute_action!
      validate_action!
      send(options["cell_action"].to_sym)
      [true, @cell_callback]
    rescue StandardError => e
      [false, e.message]
    end

    def validate_action!
      raise InvalidCellActionException, 'Invalid action' unless self.respond_to?(options["cell_action"].to_sym)
      raise InvalidCellActionException, 'Not allowed: Game has finished' if game.finished?
      raise InvalidCellActionException, 'Not allowed: Game is paused' if game.paused?
      raise InvalidCellActionException, 'Not allowed: cell cannot be cleared' if options["cell_action"] == 'clear' && !cell.can_be_cleared?
      raise InvalidCellActionException, 'Not allowed: cell is cleared' if options["cell_action"] == 'cycle_mark' && cell.cleared?
    end

    def cycle_mark
      cell.cycle_mark!
    end

    def clear
      if game.pending?
        game_svc.start(cell)
        cell.reload
      end

      clear_cell(cell)

      @cell_callback ||= game_svc.calculate_remaining_plays
    end

    private
      def explosion
        @cell_callback = "explode"
        game_svc.explode
      end

      def clear_cell(a_cell)
        return unless a_cell.can_be_cleared?

        a_cell.clear!
        return explosion if a_cell.bomb?

        clear_adjacent_cells(a_cell)
      end

      def clear_adjacent_cells(a_cell)
        return unless a_cell.without_adjacent_bombs?

        @cell_callback = "refresh_grid"
        a_cell.adjacent_cells.not_cleared.each do |adjacent_cell|
          clear_cell(adjacent_cell)
        end
      end

      def game_svc
        @_game_svc = GameService::Game.new(game)
      end
  end
end
