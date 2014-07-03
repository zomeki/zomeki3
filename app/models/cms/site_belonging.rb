class Cms::SiteBelonging < ActiveRecord::Base
  def self.table_name_prefix
    'cms_'
  end

  belongs_to :site,  :class_name => 'Cms::Site'
  belongs_to :group, :class_name => 'Sys::Group'
end
