require 'rails_helper'

RSpec.describe Sys::StorageFile, type: :model do
  it 'has a valid factory' do
    allow_any_instance_of(Sys::StorageFile).to receive(:file_existence)
    file = build(:sys_storage_file)
    expect(file).to be_valid
  end

  it 'is invalid without a path' do
    file = build(:sys_storage_file, path: nil)
    file.validate
    expect(file.errors[:path].size).to eq 1
  end
end
