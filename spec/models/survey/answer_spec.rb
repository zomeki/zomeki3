require 'rails_helper'

RSpec.describe Survey::Answer, type: :model do
  it 'has a valid factory' do
    answer = build(:survey_answer)
    expect(answer).to be_valid
  end

  it 'is invalid without a form_answer' do
    answer = build(:survey_answer, form_answer_id: nil)
    answer.validate
    expect(answer.errors[:form_answer_id].size).to eq 1
  end

  it 'is invalid without a question' do
    answer = build(:survey_answer, question_id: nil)
    answer.validate
    expect(answer.errors[:question_id].size).to eq 1
  end
end
