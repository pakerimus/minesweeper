class ApiController < ApplicationController
  protect_from_forgery with: :null_session
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def record_not_found
    render json: { error: 'not found'}, status: 404
  end

  private
    def game_action_params
      params.require(:game).permit(:game_action, :cell_action)
    end
end
