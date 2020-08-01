class Api::CellsController < ApiController
  before_action :set_user_and_game
  before_action :set_cell, only: [:show]

  def index
    render json: { cells: @game.cells }, status: 200
  end

  def show
    render json: { cell: @cell }, status: 200
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
