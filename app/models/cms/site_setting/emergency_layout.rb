class Cms::SiteSetting::EmergencyLayout < Cms::SiteSetting
  belongs_to :layout, :foreign_key => :value, :class_name => 'Cms::Layout'

  validates :value, presence: true, uniqueness: { scope: :name }

  default_scope { where(name: 'emergency_layout') }

  def current_site
    Cms::SiteSetting::EmergencyLayout.where(site_id: Core.site.id)
  end
end
