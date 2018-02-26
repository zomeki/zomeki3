class Survey::Admin::AggregationsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Survey::Content::Form.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    return redirect_to action: :index if params[:reset_criteria]
    @form = @content.forms.find(params[:form_id])
  end

  def index
    @form_answers = Survey::FormAnswersFinder.new(@form.form_answers)
                                             .search(params[:criteria])

    answers = Survey::Answer.where(form_answer_id: @form_answers.select(:id))
    @items = Survey::AggregationService.new(@form)
                                       .aggregate(answers)

    if params[:csv]
      csv = generate_csv(@form_answers, @items)
      return send_data platform_encode(csv), type: 'text/csv', filename: "answers_aggregation_#{Time.now.to_i}.csv"
    end

    _index @items
  end

  private

  def generate_csv(form_answers, items)
    require 'csv'
    CSV.generate(force_quotes: true) do |csv|
      csv << ['回答件数', form_answers.count]
      csv << []

      items.each do |item|
        csv << [item.question.title]
        csv << [self.class.helpers.strip_tags(item.question.description).strip]
        item.sums.each do |option, count|
          csv << [option, count]
        end
        csv << ['合計', item.sums.map(&:last).sum]
        csv << []
      end
    end
  end
end
