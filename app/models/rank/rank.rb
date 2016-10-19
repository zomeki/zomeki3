class Rank::Rank < ApplicationRecord
  include Sys::Model::Base

  # Content
  belongs_to :content, foreign_key: :content_id, class_name: 'Rank::Content::Rank'
  validates :content_id, :presence => true

  TERMS   = [['前日', 'previous_days'], ['先週（月曜日〜日曜日）', 'last_weeks'], ['先月', 'last_months'], ['週間（前日から一週間）', 'this_weeks']]
  TARGETS = [['PV', 'pageviews'], ['訪問者数', 'visitors']]

end
