require 'spec_helper'

describe Survey::Question do
  before do
    Core.user = FactoryGirl.build(:sys_user_system_admin)
    Core.user_group = Core.user.group
  end

  it 'has a valid factory' do
    question = FactoryGirl.build(:survey_question_1)
    expect(question).to be_valid
  end

  it 'is invalid without a title' do
    question = FactoryGirl.build(:survey_question_1, title: nil)
    expect(question).not_to be_valid
    expect(question.errors[:title].size).to eq(1)
  end

  it 'is invalid without a sort_no' do
    question = FactoryGirl.build(:survey_question_1, sort_no: nil)
    expect(question).not_to be_valid
    expect(question.errors[:sort_no].size).to eq(1)
  end
end
