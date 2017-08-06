require 'csv'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  WORDS = %w(DEBT POVERTY BURIAL MILITANT BANKRUPT SNAKE SCORPION MEASLES BEAST MENACE DIVORCE SAVAGES
             PARANOIA STARVING VOLCANO CRITICAL FRAUD MORBID PERIL MISERY STORM BACTERIA LIGHTNING TRAITOR
             CRUSHED COFFIN ABANDONED WICKED UNFAITHFUL SHRAPNEL WASP SLAVE VICTIM GRAVE HORRIBLE
             ADDICT CONTROLLING INSURGENT SMASH POWERLESS SCORCHING CONCUSSION OPERATION HELPLESS
             CHRONIC VULNERABLE PRISONER VANDAL SHOCK ALCOHOLIC MOURN SHARK UNBEARABLE AFRAID).freeze
  def index
    @words = WORDS
  end

  def create
    words_with_values = WORDS.select { |word| params[word].present? }
    @answers = params.slice(*words_with_values)
    sess_token = SecureRandom.urlsafe_base64
    file_name = Rails.root.join('tmp', "#{sess_token}.csv")
    CSV.open(file_name, 'w') do |csv|
      @answers.each { |word, rating| csv << [word, rating] }
    end

    result = `Rscript #{Rails.root}/bin/rscript/threatwords.r #{Rails.root} #{file_name}`
    puts result
    @result = result.gsub(/\[\d+\]/, '').split(/[ \n]+/).join(',')
  end
end
