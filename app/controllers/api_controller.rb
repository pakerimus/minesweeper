class ApiController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def record_not_found
    render json: { error: 'not found'}, status: 404
  end
end
