require 'spec_helper'

describe GpArticle::Comment do
  it 'has a valid factory' do
    comment = FactoryGirl.build(:gp_article_comment_1)
    expect(comment).to be_valid
  end

  it 'is invalid without a doc' do
    comment = FactoryGirl.build(:gp_article_comment_1, doc: nil)
    expect(comment).not_to be_valid
    expect(comment.errors[:doc_id].size).to eq(1)
  end

  it 'is invalid without a state' do
    comment = FactoryGirl.build(:gp_article_comment_1, state: nil)
    expect(comment).not_to be_valid
    expect(comment.errors[:state].size).to eq(1)
  end
end
