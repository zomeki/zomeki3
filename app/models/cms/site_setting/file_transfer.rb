# encoding: utf-8
class Cms::SiteSetting::FileTransfer < Cms::SiteSetting

  validates :value, uniqueness: { scope: :name }

end
