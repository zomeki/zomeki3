require 'spec_helper'

describe Survey::FormAnswer do
  before do
    Core.user = FactoryGirl.build(:sys_user_system_admin)
    Core.user_group = Core.user.group
  end

  it 'has a valid factory' do
    answer = FactoryGirl.build(:survey_form_answer_1)
    expect(answer).to be_valid
  end

  it 'is invalid without a form' do
    answer = FactoryGirl.build(:survey_form_answer_1, form_id: nil)
    expect(answer).not_to be_valid
    expect(answer.errors[:form_id].size).to eq(1)
  end
end
