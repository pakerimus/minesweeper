class Api::CellsController < ApiController
  before_action :set_user_and_game
  before_action :set_cell, only: [:show, :execute]

  def index
    render json: { cells: @game.cells.for_grid }, status: 200
  end

  def show
    render json: { cell: @cell }, status: 200
  end

  def execute
    cell_service = GameService::Cell.new(@game, @cell, **game_action_params)
    status, message = cell_service.execute_action!
    json_response = { result: message, game: @game.reload, cell: @cell.reload }
    render json: json_response, status: (status ? 200 : 422)
  end

  private
    def set_user_and_game
      @user = User.find(params[:user_id])
      @game = @user.games.find(params[:game_id])
    end

    def set_cell
      @cell = @game.cells.find(params[:id])
    end
end
