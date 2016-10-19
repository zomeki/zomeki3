class Rank::Content::Rank < Cms::Content
  default_scope { where(model: 'Rank::Rank') }

  has_one :public_node, -> { public_state.order(:id) },
    foreign_key: :content_id, class_name: 'Cms::Node'

  has_many :settings, -> { order(:sort_no) },
    foreign_key: :content_id, class_name: 'Rank::Content::Setting', dependent: :destroy

  has_many :pieces, foreign_key: :content_id, class_name: 'Rank::Piece::Rank', dependent: :destroy
  has_many :ranks, foreign_key: :content_id, class_name: 'Rank::Total', dependent: :destroy

  def access_token
    credentials = GoogleOauth2Installed.credentials
    credentials[:oauth2_client_id] = setting_extra_value(:google_oauth, :client_id)
    credentials[:oauth2_client_secret] = setting_extra_value(:google_oauth, :client_secret)
    credentials[:oauth2_scope] = 'https://www.googleapis.com/auth/analytics.readonly'
    credentials[:oauth2_token] = setting_extra_value(:google_oauth, :oauth2_token)
    GoogleOauth2Installed::AccessToken.new(credentials).access_token
  end
end
