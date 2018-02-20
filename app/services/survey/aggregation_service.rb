class Survey::AggregationService < ApplicationService
  def initialize(form)
    @form = form
  end

  def aggregate(answers = @form.answers)
    aggs = []

    @form.questions.each do |question|
      count = case question.form_type
              when 'select', 'radio_button'
                aggregate_single_select(answers, question)
              when 'check_box'
                aggregate_multi_select(answers, question)
              else
                next
              end

      agg = Survey::AggregationModel.new(question: question)
      question.form_options_for_select.each do |option|
        agg.sums[option] = count[option].to_i
      end
      aggs << agg
    end

    aggs
  end

  private

  def aggregate_single_select(answers, question)
    answers.where(question: question).reorder(nil).group(:content).count
  end

  def aggregate_multi_select(answers, question)
    count = question.form_options_for_select.map { |option| [option, 0] }.to_h
    answers.where(question: question).find_each do |answer|
      answer.content.split(',').each do |option|
        count[option] += 1 if count.key?(option)
      end
    end
    count
  end
end
