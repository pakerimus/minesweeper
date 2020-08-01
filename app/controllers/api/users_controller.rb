class Api::UsersController < ApiController
  def create
    user = User.find_or_create_by(user_params)
    render json: { user: user }, status: 200
  rescue StandardError => e
    render json: { error: e.message }, status: 400
  end

  private
    def user_params
      params.require(:user).permit(:name)
    end
end
