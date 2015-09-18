class GpArticle::Comment < ActiveRecord::Base
  include Sys::Model::Base

  #TODO: migrate to strong_parameters
  #attr_accessible :state,
  #                :author_name,
  #                :author_email,
  #                :author_url,
  #                :body,
  #                :posted_at

  include StateText

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]

  scope :public_state, -> { where(state: 'public') }

  belongs_to :doc

  validates :doc_id, :presence => true
  validates :state, :presence => true

  after_initialize :set_defaults
  after_save :set_display_attributes

  scope :content_and_criteria, ->(content, criteria){
    comments = self.arel_table
    docs = GpArticle::Doc.arel_table
    rel = all.joins(:doc).readonly(false)
    rel = rel.where(docs[:content_id].eq(content.id))
    rel = rel.search_with_text(:body, criteria[:free_word]) if criteria[:free_word].present?
    rel = rel.search_with_text(:author_name, criteria[:author_name]) if criteria[:author_name].present?
    rel
  }

  validates :author_name, :presence => true, :length => {maximum: 200}

  def editable?
    doc.editable?
  end

  def deletable?
    doc.deletable?
  end

  private

  def set_defaults
    self.state = STATE_OPTIONS.last.last if self.has_attribute?(:state) && self.state.nil?
  end

  def set_display_attributes
    self.update_column(:posted_at, self.created_at) if self.posted_at.nil?
  end
end
