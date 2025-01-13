# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Sessions' do
  let(:json_response) { JSON.parse(response.body, symbolize_names: true) }

  describe '#create' do # rubocop:disable RSpec/EmptyExampleGroup
    path '/api/v1/users/sign_in' do
      post 'creates new user session' do
        tags 'Sessions'
        consumes 'application/json'
        parameter name: :params, in: :body, schema: {
          type: :object,
          properties: {
            email: { type: :string },
            password: { type: :string },
          }
        }

        response(200, 'logins new user successfully') do
          let(:params) do
            {
              user: {
                email: 'sample@email.com',
                password: '12345678',
              }
            }
          end

          before do
            create(:user, email: 'sample@email.com', password: '12345678')
          end

          run_test! do |response|
            expect(response).to have_http_status :ok
            expect(json_response).to include(
              status: include(
                code: 200,
                data: include(
                  user: include(email: 'sample@email.com')
                ),
                message: 'Logged in successfully.',
              )
            )
          end
        end
      end
    end
  end

  describe '#destroy' do # rubocop:disable RSpec/EmptyExampleGroup
    path '/api/v1/users/sign_out' do
      delete 'logs out user' do
        tags 'Sessions'
        consumes 'application/json'
        parameter name: :Authorization, in: :header, type: :string

        response(200, 'logins new user successfully') do
          let(:user) do
            create(
              :user,
              email: 'test@email.com',
              password: 'password',
              password_confirmation: 'password'
            )
          end

          let(:Authorization) do
            payload = { sub: user.id }
            JWT.encode(
              payload,
              Rails.application.credentials.devise_jwt_secret_key!,
              'HS256'
            )
          end

          run_test! do |response|
            expect(response).to have_http_status :ok
            expect(json_response).to include(
              message: 'Logged out successfully.',
              status: 200
            )
          end
        end
      end
    end
  end
end