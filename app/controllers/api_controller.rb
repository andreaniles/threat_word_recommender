class ApiController < ActionController::Base
  protect_from_forgery with: :exception

  def words
    words_with_values = ApplicationController::WORDS.select { |word| params[word].present? }
    @ratings = params.slice(*words_with_values)
    @result = WordRecommender.new(@ratings).recommended_words
puts '*'*100
puts @result
    render json: @result
  end
end
