FactoryGirl.define do
  factory :sys_storage_file, class: 'Sys::StorageFile' do
    sequence(:path) {|n| "/path/to/storage/file#{n}.txt" }
    available true
  end
end
