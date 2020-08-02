module GameService
  class Game
    attr_accessor :game, :options

    def initialize(game, **options)
      @game = game
      @options = options
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
      send(options[:game_action].to_sym)
      [true, 'ok']
    rescue StandardError => e
      [false, e.message]
    end

    def validate_action!
      raise 'Invalid action' unless self.respond_to?(options[:game_action].to_sym)
      raise 'Not allowed: Game has finished' if game.finished?

      if ['start', 'continue'].includes?(options[:game_action]) && started? ||
         options[:game_action] == 'pause' && paused?
        raise 'Not allowed: redundant'
      end
    end

    def start
      starting_cell = game.cells.by_position(options[:row], options[:column]).take
      game.place_bombs(starting_cell)
      game.cells.normal.map(&:calculate_adjacent_bombs)
      starting_cell.clear!
      game.update(state: 'started', last_started_at: Time.zone.now)
    end

    def pause
      game.update(state: 'paused', last_started_at: nil, total_time: total_time)
    end

    def continue
      game.update(state: 'started', last_started_at: Time.zone.now)
    end

    def abandon
      finish_with_state('abandoned')
    end

    def explode
      finish_with_state('lost')
    end

    def calculate_remaining_plays
      finish_with_state('won') if game.available_plays.zero?
    end

    private
      def total_time
        seconds = Time.zone.now - game.last_started_at
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
