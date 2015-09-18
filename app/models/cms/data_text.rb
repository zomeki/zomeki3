# encoding: utf-8
class Cms::DataText < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Page
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Site
  include Cms::Model::Rel::Concept
  include Cms::Model::Auth::Concept

  include StateText

  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'
  
  validates :state, :title, :body, presence: true
  validates :name, presence: true, uniqueness: { scope: :concept_id },
    format: { with: /\A[0-9a-zA-Z\-_]+\z/, if: "name.present?", message: "は半角英数字、ハイフン、アンダースコアで入力してください。" }

  scope :public_state, -> { where(state: 'public') }
end
