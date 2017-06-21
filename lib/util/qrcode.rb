class Util::Qrcode
  require 'rqrcode_png'

  class << self
    def create(text, size: 8)
      return nil if text.blank?

      qr = RQRCode::QRCode.new(text, size: size, level: :h)
      png = qr.to_img
      png.resize(114, 114).to_blob
    rescue => e
      warn_log "#{__FILE__}:#{__LINE__} #{e.message}"
      return nil
    end
  end
end
