# frozen_string_literal: true

class Api::V1::Users::SessionsController < Devise::SessionsController
  def respond_to_on_destroy # rubocop:disable Metrics/AbcSize
    if request.headers['Authorization'].present?
      jwt_payload = JWT.decode(request.headers['Authorization'].split.last, Rails.application.credentials.devise_jwt_secret_key!).first
      current_user = User.find(jwt_payload['sub'])
    end
    
    if current_user
      render json: {
        status: 200,
        message: 'Logged out successfully.'
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "Couldn't find an active session."
      }, status: :unauthorized
    end
  end
  
  def respond_with(current_user, _opts = {})
    render json: {
      status: { 
        code: 200, message: 'Logged in successfully.',
        data: { user: UserBlueprint.render_as_hash(current_user) }
      }
    }, status: :ok
  end
end
