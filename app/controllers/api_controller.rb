class ApiController < ActionController::Base
  protect_from_forgery with: :exception

  def words
    words_with_values = ApplicationController::WORDS.select { |word| params[word].present? }
    @ratings = params.slice(*words_with_values)
    mode = params[:location] == 'local' ? 1 : 2
    @result = WordRecommender.new(@ratings, mode).recommended_words
    render json: @result
  end
end
