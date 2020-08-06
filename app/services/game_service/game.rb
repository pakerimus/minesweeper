module GameService
  class Game
    attr_accessor :game, :options

    class InvalidGameActionException < StandardError; end

    def initialize(game, **options)
      @game = game
      @options = options
      @options["game_action"] ||= ''
      @game_callback = nil
    end

    def create_board!
      game.height.times do |row|
        game.width.times do |column|
          game.cells.create(row: row+1, column: column+1)
        end
      end
    end

    def execute_action!
      validate_action!
      send(options["game_action"].to_sym)
      [true, @game_callback]
    rescue StandardError => e
      [false, e.message]
    end

    def validate_action!
      raise InvalidGameActionException, 'Invalid action' unless self.respond_to?(options["game_action"].to_sym)
      raise InvalidGameActionException, 'Not allowed: Action is reserved' if ['start', 'explode'].include?options["game_action"]
      raise InvalidGameActionException, 'Not allowed: Game has finished' if game.finished?
      raise InvalidGameActionException, 'Not allowed: Game has not started' if game.pending?
      raise InvalidGameActionException, 'Not allowed: redundant' if options["game_action"] == 'continue' && game.started?
      raise InvalidGameActionException, 'Not allowed: redundant' if options["game_action"] == 'pause' && game.paused?
    end

    def start(starting_cell)
      place_bombs(starting_cell)
      game.cells.normal.map(&:calculate_adjacent_bombs)
      game.update(state: 'started', last_started_at: Time.zone.now)
    end

    def pause
      game.update(state: 'paused', last_started_at: nil, total_time: total_time)
    end

    def continue
      game.update(state: 'started', last_started_at: Time.zone.now)
      @game_callback = "refresh_grid"
    end

    def abandon
      finish_with_state('abandoned')
      @game_callback = "refresh_grid"
    end

    def explode
      finish_with_state('lost')
    end

    def calculate_remaining_plays
      return unless game.available_plays.zero?

      finish_with_state('won')

      'won'
    end

    def place_bombs(starting_cell)
      return if game.cells.bombs.any?

      eligible_cells = game.cells.normal.where.not(id: starting_cell.adjacent_cells.pluck(:id))
      game.bombs.times do
        random_normal_cell = eligible_cells.reload.sample
        random_normal_cell.place_bomb!
      end
    end

    private
      def total_time
        now = Time.zone.now
        seconds = now - (game.last_started_at || now)
        game.total_time + seconds
      end

      def finish_with_state(new_state)
        game.update(state: new_state, last_started_at: nil, total_time: total_time)
        clear_all_cells
      end

      def clear_all_cells
        game.cells.update_all(cleared: true)
      end
  end
end
