class GpCategory::TemplateModule < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Content

  column_attribute :num_docs, default: 10
  enum_ish :module_type, [:categories_1, :categories_2, :categories_3,
                          :categories_summary_1, :categories_summary_2, :categories_summary_3,
                          :docs_1, :docs_2, :docs_3, :docs_4, :docs_5, :docs_6, :docs_7, :docs_8],
                         default: :categories_1
  enum_ish :wrapper_tag, [:li, :article, :section], default: :li

  belongs_to :content, class_name: 'GpCategory::Content::CategoryType', required: true

  after_save     GpCategory::Publisher::TemplateModuleCallbacks.new, if: :saved_changes?
  before_destroy GpCategory::Publisher::TemplateModuleCallbacks.new, prepend: true

  validates :name, presence: true, uniqueness: { scope: :content_id, case_sensitive: false },
                   format: { with: /\A[0-9A-Za-z\-_]+\z/, if: -> { name.present? } }
  validates :title, presence: true

  def gp_article_content_ids=(val)
    self.module_type_feature = YAML.dump(val.select(&:present?).map(&:to_i))
  end

  def gp_article_content_ids
    YAML.load(module_type_feature.presence || '[]')
  end

  def gp_article_contents
    if gp_article_content_ids.present?
      GpArticle::Content::Doc.where(id: gp_article_content_ids).order(:id)
    else
      GpArticle::Content::Doc.none
    end
  end

  class << self
    def grouped_module_type_options
      cats, docs = module_type_options.partition { |opt| opt.last =~ /cat/ }
      { 'カテゴリ一覧' => cats, '記事一覧' => docs }
    end
  end
end
