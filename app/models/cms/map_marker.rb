class Cms::MapMarker < ApplicationRecord
  include Sys::Model::Base
  
  validates :lat, :lng, presence: true
  
  def js_params
    name = self.name.gsub(/'/, "\\\\'").gsub(/\r\n|\r|\n/, "<br />")
    %Q(#{lat}, #{lng}, '#{name}')
  end
end
