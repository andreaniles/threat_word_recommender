class WordRecommender
  def initialize(ratings, mode, num_to_recommend = 60)
    @ratings = ratings
    @mode = mode
    @num_to_rec = num_to_recommend
  end

  def recommended_words
    return ['Please rate at least 5 words'] unless @ratings.size >= 5
    write_ratings_to_temp_file
    result =
      `Rscript #{Rails.root}/bin/rscript/threatwords.r #{Rails.root} #{file_name} #{@mode} #{@num_to_rec}`
    parse_result(result)
  end

  private

  def parse_result(r_script_output)
    result = r_script_output.
             gsub(/\[|\d+|\,|\] /, '').delete('"').split(/[ \n]+/).
             map(&:strip).select(&:present?)
    result = result.in_groups_of(2) if @mode == 3
    result[0..-1]
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
