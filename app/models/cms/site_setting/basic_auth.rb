class Cms::SiteSetting::BasicAuth < Cms::SiteSetting

  validates :value, presence: true, uniqueness: { scope: :name }

  default_scope { where(name: 'basic_auth_state') }

end
