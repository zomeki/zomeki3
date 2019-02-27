class Cms::Piece::SnsPart < Cms::Piece
  SETTING_KEYS = [:twitter, :fb_like, :mixi, :line, :mixi_data_key]
  SETTING_NAMES = {twitter: 'Twitter ツイート', fb_like: 'Facebook いいね！', mixi: 'mixi チェック', line: 'LINE で送る', mixi_data_key: ''}.with_indifferent_access
end
