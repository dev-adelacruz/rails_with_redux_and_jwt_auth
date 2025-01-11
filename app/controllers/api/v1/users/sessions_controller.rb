# frozen_string_literal: true

class Api::V1::Users::SessionsController < Devise::SessionsController
  def respond_with(current_user, _opts = {})
    render json: {
      status: { 
        code: 200, message: 'Logged in successfully.',
        data: { user: UserBlueprint.render_as_hash(current_user) }
      }
    }, status: :ok
  end
end
