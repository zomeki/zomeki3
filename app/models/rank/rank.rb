class Rank::Rank < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Rel::Content

  # Content
  belongs_to :content, class_name: 'Rank::Content::Rank', required: true

  TERMS   = [['先月', 'last_months'], ['先週（月曜日〜日曜日）', 'last_weeks'], ['週間（前日から一週間）', 'this_weeks'], ['前日', 'previous_days']]
  TARGETS = [['PV', 'pageviews'], ['訪問者数', 'visitors']]
end
