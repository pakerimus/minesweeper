class Api::GamesController < ApiController
  before_action :set_user
  before_action :set_game, only: [:show, :destroy, :execute]

  def index
    render json: { games: @user.games }, status: 200
  end

  def create
    @game = @user.games.new(game_params)
    if @game.save
      render json: { game: @game }, status: 201
    else
      render json: { error: @game.errors.full_messages.to_sentence }, status: 400
    end
  end

  def show
    render json: { game: @game, cells: @game.cells.for_grid }, status: 200
  end

  def destroy
    @game.destroy!
    head 200
  end

  def execute
    game_service = GameService::Game.new(@game, **game_action_params)
    status, message = game_service.execute_action!
    render json: { result: message, game: @game.reload }, status: (status ? 200 : 422)
  end

  private
    def set_user
      @user = User.find(params[:user_id])
    end

    def set_game
      @game = @user.games.find(params[:id])
    end

    def game_params
      params.require(:game).permit(:width, :height, :bombs)
    end
end
