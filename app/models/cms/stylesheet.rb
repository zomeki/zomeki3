class Cms::Stylesheet < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Auth::Concept

  after_save :update_descendants, if: :path_changed?
  after_destroy :destroy_descendants, if: :path_changed?

  validates :concept_id, presence: true, on: :create

  private

  def update_descendants
    self.class.where(self.class.arel_table[:path].matches("#{path_was}/%"))
        .replace_for_all(:path, "#{path_was}/", "#{path}/")
  end

  def destroy_descendants
    self.class.where(self.class.arel_table[:path].matches("#{path}/%")).destroy_all
  end
end
