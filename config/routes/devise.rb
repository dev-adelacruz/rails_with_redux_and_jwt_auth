# frozen_string_literal: true

devise_for :users, controllers: {
  sessions: 'api/v1/users/sessions'
}
