Rails.application.routes.draw do
  root to: 'application', action: 'index'

  get 'application/index'
  post 'application/create'
end
