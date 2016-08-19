class Cms::Model::Tool::Export < ActiveRecord::Base
  self.table_name = "cms_concepts" #dummy
  
  attr_accessor :concept_id
  attr_accessor :target
  
  validates :concept_id, presence: true
  
  # empty methods
  def seve; end
  def destroy; end
end
