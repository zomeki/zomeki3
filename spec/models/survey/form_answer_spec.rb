require 'rails_helper'

RSpec.describe Survey::FormAnswer, type: :model do
  it 'has a valid factory' do
    answer = build(:survey_form_answer)
    expect(answer).to be_valid
  end

  it 'is invalid without a form' do
    answer = build(:survey_form_answer, form_id: nil)
    answer.validate
    expect(answer.errors[:form_id].size).to eq 1
  end
end
