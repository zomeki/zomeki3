class Cms::KanaDictionary::Maker
  include ActiveModel::Model
  include ActiveModel::Callbacks

  attr_accessor :site_id, :dic_path, :errors

  define_model_callbacks :save_files
  after_save_files FileTransferCallbacks.new(:dic_path), if: -> { site_id }

  def initialize(site_id: nil)
    @site_id = site_id
    @dic_path = Cms::KanaDictionary.user_dic(@site_id)
    @errors = []
  end

  def make_dic
    @errors = []

    data = load_dic_csv
    if data.blank?
      @errors << "登録データが見つかりません。"
      return false
    end

    csv = Tempfile::new(["mecab", ".csv"], '/tmp')
    csv.puts(data)
    csv.close

    run_callbacks :save_files do
      require 'open3'
      mecab_index = Zomeki.config.application['cms.mecab_index']
      mecab_dic = Zomeki.config.application['cms.mecab_dic']
      out = Open3.capture3(mecab_index, '-d', mecab_dic, '-u', @dic_path, '-f', 'utf8', '-t', 'utf8', csv.path)[0]
      @errors << "辞書の作成に失敗しました" unless out =~ /done!$/
    end

    csv.close(true)

    return @errors.size == 0
  end

  private

  def load_dic_csv
    data = []
    items = Cms::KanaDictionary.where(site_id: @site_id ? [@site_id, nil] : [nil]).order(:id)
    items.each do |item|
      item.convert_csv if item.mecab_csv == nil
      data << item.mecab_csv if item.mecab_csv.present?
    end
    data.join("\n")
  end
end
