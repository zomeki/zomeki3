require 'spec_helper'

describe GpCategory::Template do
  it 'has a valid factory' do
    template = FactoryGirl.build(:gp_category_template_1)
    expect(template).to be_valid
  end

  it 'is invalid without a content' do
    template = FactoryGirl.build(:gp_category_template_1, content: nil)
    expect(template).not_to be_valid
    expect(template.errors[:content_id].size).to eq(1)
  end

  it 'is invalid without a name' do
    template = FactoryGirl.build(:gp_category_template_1, name: nil)
    expect(template).not_to be_valid
    expect(template.errors[:name].size).to eq(1)
  end

  it 'is invalid without a title' do
    template = FactoryGirl.build(:gp_category_template_1, title: nil)
    expect(template).not_to be_valid
    expect(template.errors[:title].size).to eq(1)
  end
end
