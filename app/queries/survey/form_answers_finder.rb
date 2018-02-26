class Survey::FormAnswersFinder < ApplicationFinder
  def initialize(form_answers = Survey::FormAnswer.all)
    @form_answers = form_answers
  end

  def search(criteria)
    criteria ||= {}

    if criteria[:start_date] || criteria[:end_date]
      start_date = Date.parse(criteria[:start_date]) rescue nil
      end_date = Date.parse(criteria[:end_date]) rescue nil
      @form_answers = @form_answers.dates_intersects(:created_at, :created_at, start_date.try(:beginning_of_day), end_date.try(:end_of_day))
    end

    @form_answers
  end
end
