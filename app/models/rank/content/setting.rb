class Rank::Content::Setting < Cms::ContentSetting
  set_config :web_property_id,
    name: 'Googleアナリティクス　トラッキングID',
    comment: '例：UA-33912981-1'
  set_config :show_count,
    name: 'アクセス数の表示',
    options: [['表示する', 1], ['表示しない', 0]]
  set_config :exclusion_url,
    name: '除外URL',
    form_type: :text,
    lower_text: 'スペースまたは改行で複数指定できます。'
  set_config :google_oauth,
    name: 'Google OAuth'

  belongs_to :content, foreign_key: :content_id, class_name: 'Rank::Content::Rank'

  def extra_values=(params)
    ex = extra_values
    case name
    when 'google_oauth'
      ex[:client_id] = params[:client_id].to_s
      ex[:client_secret] = params[:client_secret].to_s
      ex[:auth_code] = params[:auth_code].to_s

      if ex[:client_id].present? && ex[:client_secret].present?
        credentials = GoogleOauth2Installed.credentials
        credentials[:oauth2_client_id] = ex[:client_id]
        credentials[:oauth2_client_secret] = ex[:client_secret]
        credentials[:oauth2_scope] = 'https://www.googleapis.com/auth/analytics.readonly'

        setup = GoogleOauth2Installed::Setup.new(credentials)
        ex[:auth_url] = setup.zomeki_get_auth_url if ex[:auth_url].blank?
        if ex[:auth_code].present?
          token = setup.zomeki_get_access_token(ex[:auth_code])
          ex[:oauth2_token] = {access_token: token.token.to_s,
                                         refresh_token: token.refresh_token.to_s,
                                         expires_at: token.expires_at.to_i}
          ex[:auth_code] = nil
        end
      else
        ex[:auth_url] = nil
        ex[:auth_code] = nil
        ex[:oauth2_token] = nil
      end
      self.value = ex[:oauth2_token] ? '設定済'  : nil
    end
    super(ex)
  end
end
