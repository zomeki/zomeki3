require 'rails_helper'

RSpec.describe Survey::Form, type: :model do
  it 'has a valid factory' do
    form = build(:survey_form)
    expect(form).to be_valid
  end

  it 'is invalid without a title' do
    form = build(:survey_form, title: nil)
    form.validate
    expect(form.errors[:title].size).to eq 1
  end
end
