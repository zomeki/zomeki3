require 'rails_helper'

RSpec.describe Cms::DataFile, type: :model do
  before :all do
    Zomeki.config.application['sys.file_text_extraction'] = true
  end

  it 'has a valid factory' do
    data_file = build(:cms_data_file)
    expect(data_file).to be_valid
  end

  context 'with txt file' do
    it 'extracts file content' do
      data_file = create(:cms_data_file)
      expect(data_file.extracted_text).to match File.read(data_file.upload_path)
    end
  end

  context 'with pdf file' do
    it 'extracts file content' do
      data_file = create(:cms_data_file, :pdf)
      expect(data_file.extracted_text).to match /これはPDFファイル\(pdf\)です。/
    end
  end

  context 'with doc file' do
    it 'extracts file content' do
      data_file = create(:cms_data_file, :doc)
      expect(data_file.extracted_text).to match /これはワードファイル\(doc\)です。/
    end
  end

  context 'with xls file' do
    it 'extracts file content' do
      data_file = create(:cms_data_file, :xls)
      expect(data_file.extracted_text).to match /これはエクセルファイル\(xls\)です。/
    end
  end

  context 'with ppt file' do
    it 'extracts file content' do
      data_file = create(:cms_data_file, :ppt)
      expect(data_file.extracted_text).to match /これはパワーポイントファイル\(ppt\)です。/
    end
  end

  context 'with jpg file' do
    it 'extracts file content' do
      data_file = create(:cms_data_file, :jpg)
      expect(data_file.extracted_text).to be_nil
    end
  end
end
