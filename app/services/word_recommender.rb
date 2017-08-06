class WordRecommender
  def initialize(ratings)
    @ratings = ratings
  end

  def recommended_words
    return ['nothing entered'] unless @ratings.any?
    write_ratings_to_temp_file
    result = `Rscript #{Rails.root}/bin/rscript/threatwords.r #{Rails.root} #{file_name}`
    parse_result(result)
  end

  private

  def parse_result(r_script_output)
    r_script_output.gsub(/\[\d+\] /, '').delete('"').split(/[ \n]+/).map(&:strip).select(&:present?)
  end

  def sess_token
    @sess_token ||= SecureRandom.urlsafe_base64
  end

  def file_name
    @file_name ||= Rails.root.join('tmp', "#{sess_token}.csv")
  end

  def write_ratings_to_temp_file
    CSV.open(file_name, 'w') do |csv|
      csv << %w(word rating)
      @ratings.each { |word, rating| csv << [word, rating] }
    end
  end
end
