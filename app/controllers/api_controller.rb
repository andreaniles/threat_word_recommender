class ApiController < ActionController::Base
  protect_from_forgery with: :exception

  def words
    render json: [1,2,3]
  end
end
