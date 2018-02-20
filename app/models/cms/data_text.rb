class Cms::DataText < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Site
  include Cms::Model::Rel::Concept
  include Cms::Model::Rel::Bracketee
  include Cms::Model::Auth::Concept::Creator

  enum_ish :state, [:public, :closed]

  belongs_to :concept

  after_save     Cms::Publisher::BracketeeCallbacks.new, if: :changed?
  before_destroy Cms::Publisher::BracketeeCallbacks.new

  validates :state, :title, :body, presence: true
  validates :name, presence: true,
                   uniqueness: { scope: :concept_id, case_sensitive: false },
                   format: { with: /\A[0-9a-zA-Z\-_]+\z/, if: -> { name.present? }, message: :invalid_bracket_name }

  scope :public_state, -> { where(state: 'public') }
end
