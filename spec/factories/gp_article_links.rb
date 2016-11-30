FactoryGirl.define do
  factory :gp_article_link, class: 'GpArticle::Link' do
    doc_id 1
    body 'こちら'
    url 'http://example.com'
  end
end
