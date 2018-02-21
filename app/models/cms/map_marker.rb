class Cms::MapMarker < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site

  belongs_to :map

  validates :lat, :lng, presence: true

  define_site_scope :map

  def js_params
    name = self.name.gsub(/'/, "\\\\'").gsub(/\r\n|\r|\n/, "<br />")
    %Q(#{lat}, #{lng}, '#{name}')
  end
end
