require 'rails_helper'

RSpec.describe Cms::DataFile, type: :model do
  before :all do
    first_site = create(:cms_site, :first)
    initialize_core first_site.full_uri
  end

  it 'has a valid factory' do
    data_file = build(:cms_data_file)
    expect(data_file).to be_valid
  end

  it 'extracts file content' do
    data_file = create(:cms_data_file)
    expect(data_file.extracted_text).to match File.read(data_file.upload_path)
  end
end
