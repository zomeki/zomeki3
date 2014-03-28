# encoding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :cms_node_1, :class => 'Cms::Node' do
    id 1
    unid 10
    concept_id 1
    site_id 4
    state 'public'
    created_at '2014-03-01 18:16:02'
    updated_at '2014-03-01 18:16:02'
    recognized_at nil
    published_at '2014-03-02 11:12:03'
    parent_id 1
    route_id 1
    content_id nil
    model 'Cms::Page'
    directory 0
    layout_id nil
    name 'index.html'
    title 'ぞめきトップ'
    body 'ぞめきのトップです。'
    mobile_title nil
    mobile_body nil
    sitemap_state 'visible'
    sitemap_sort_no nil
  end
end
