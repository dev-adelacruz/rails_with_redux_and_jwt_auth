# frozen_string_literal: true

devise_for :users, singular: :user, controllers: {
  registrations: 'api/v1/users/registrations'
}
