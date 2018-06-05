class Cms::MapMarker < ApplicationRecord
  include Sys::Model::Base

  belongs_to :map

  validates :lat, :lng, presence: true, numericality: true

  nested_scope :in_site, through: :map

  def js_params
    name = self.name.gsub(/'/, "\\\\'").gsub(/\r\n|\r|\n/, "<br />")
    %Q(#{lat}, #{lng}, '#{name}')
  end
end
