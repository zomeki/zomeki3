include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :cms_data_file, class: 'Cms::DataFile' do
    site_id 1
    concept_id 1
    node_id 1
    state { %w!public closed!.sample }
    published_at { Faker::Time.between(1.month.ago, 1.month.since) }
    sequence(:name) {|n| "file_#{n}.txt" }
    sequence(:title) {|n| "ファイル#{n}" }
    mime_type 'text/plain'
    size { SecureRandom.random_number 10.megabytes }
    image_is 2
    image_width nil
    image_height nil
    thumb_width nil
    thumb_height nil
    thumb_size nil
    extracted_text nil
    file { fixture_file_upload(Rails.root.join('spec/fixtures/files/abc.txt'), 'text/plain') }

    trait :pdf do
      sequence(:name) {|n| "file_#{n}.pdf" }
      mime_type { Rack::Mime.mime_type '.pdf' }
      file { fixture_file_upload(Rails.root.join('spec/fixtures/files/acrobat.pdf'), 'application/pdf') }
    end

    trait :doc do
      sequence(:name) {|n| "file_#{n}.doc" }
      mime_type { Rack::Mime.mime_type '.doc' }
      file { fixture_file_upload(Rails.root.join('spec/fixtures/files/word.doc'), 'application/msword') }
    end

    trait :xls do
      sequence(:name) {|n| "file_#{n}.xls" }
      mime_type { Rack::Mime.mime_type '.xls' }
      file { fixture_file_upload(Rails.root.join('spec/fixtures/files/excel.xls'), 'application/vnd.ms-excel') }
    end

    trait :ppt do
      sequence(:name) {|n| "file_#{n}.ppt" }
      mime_type { Rack::Mime.mime_type '.ppt' }
      file { fixture_file_upload(Rails.root.join('spec/fixtures/files/power_point.ppt'), 'application/vnd.ms-powerpoint') }
    end

    trait :jpg do
      sequence(:name) {|n| "file_#{n}.jpg" }
      mime_type { Rack::Mime.mime_type '.jpg' }
      file { fixture_file_upload(Rails.root.join('spec/fixtures/files/logo.jpg'), 'image/jpeg') }
    end
  end
end
