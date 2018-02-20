class Survey::AnswersFinder < ApplicationFinder
  def initialize(answers = Survey::Answer.all)
    @answers = answers
  end

  def search(criteria)
    criteria ||= {}

    if criteria[:start_date] || criteria[:end_date]
      start_date = Date.parse(criteria[:start_date]) rescue nil
      end_date = Date.parse(criteria[:end_date]) rescue nil
      @answers = @answers.dates_intersects(:created_at, :created_at, start_date.try(:beginning_of_day), end_date.try(:end_of_day))
    end

    @answers
  end
end
