class Survey::Admin::AggregationsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Survey::Content::Form.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    return redirect_to action: :index if params[:reset_criteria]
    @form = @content.forms.find(params[:form_id])
  end

  def index
    answers = Survey::AnswersFinder.new(@form.answers)
                                  .search(params[:criteria])

    @items = Survey::AggregationService.new(@form).aggregate(answers)

    if params[:csv]
      csv = generate_csv(@items)
      return send_data platform_encode(csv), type: 'text/csv', filename: "answers_aggregation_#{Time.now.to_i}.csv"
    end

    _index @items
  end

  private

  def generate_csv(items)
    require 'csv'
    CSV.generate(force_quotes: true) do |csv|
      items.each do |item|
        csv << [item.question.title]
        csv << [self.class.helpers.strip_tags(item.question.description).strip]
        item.sums.each do |option, count|
          csv << [option, count]
        end
        csv << []
      end
    end
  end
end
