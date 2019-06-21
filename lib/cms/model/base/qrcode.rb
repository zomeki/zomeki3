module Cms::Model::Base::Qrcode
  extend ActiveSupport::Concern

  QRCODE_FILENAME = 'qrcode.png'

  included do
    enum_ish :qrcode_state, [:visible, :hidden]
  end

  def qrcode_visible?
    qrcode_state == 'visible'
  end

  concerning :Publication do
    def qrcode_public_uri
      uri = public_uri.end_with?('/') ? public_uri : ::File.dirname(public_uri)
      ::File.join(uri, QRCODE_FILENAME)
    end

    def qrcode_preview_uri
      uri = preview_uri.end_with?('/') ? preview_uri : ::File.dirname(preview_uri)
      ::File.join(uri, QRCODE_FILENAME)
    end

    def qrcode_path
      ::File.join(::File.dirname(public_path), QRCODE_FILENAME)
    end

    def qrcode_smart_phone_path
      ::File.join(::File.dirname(public_smart_phone_path), QRCODE_FILENAME)
    end

    def publish_qrcode
      publish_qrcode_to(qrcode_path)
      return true
    end

    def publish_smart_phone_qrcode
      publish_qrcode_to(qrcode_smart_phone_path, dependent: :smart_phone)
      return true
    end

    private

    def publish_qrcode_to(path, options = {})
      return true unless qrcode_visible?
  
      qrcode = Util::Qrcode.create(public_full_uri)
      return true unless qrcode
  
      dep = ['qrcode', options[:dependent]].compact.join('_')
      pub = Sys::Publisher.where(publishable: self, dependent: dep).first_or_initialize
      pub.publish_with_digest(qrcode, path)
    end
  end
end
