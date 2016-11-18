require 'rails_helper'

RSpec.describe GpArticle::Link, type: :model do
  it 'has a valid factory' do
    link = build(:gp_article_link)
    expect(link).to be_valid
  end

  it 'is invalid without a doc' do
    link = build(:gp_article_link, doc: nil)
    link.validate
    expect(link.errors[:doc_id].size).to eq 1
  end
end
