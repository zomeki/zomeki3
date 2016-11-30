require 'rails_helper'

RSpec.describe Survey::Question, type: :model do
  it 'has a valid factory' do
    question = build(:survey_question)
    expect(question).to be_valid
  end

  it 'is invalid without a title' do
    question = build(:survey_question, title: nil)
    question.validate
    expect(question.errors[:title].size).to eq 1
  end

  it 'is invalid without a sort_no' do
    question = build(:survey_question, sort_no: nil)
    question.validate
    expect(question.errors[:sort_no].size).to eq 1
  end
end
