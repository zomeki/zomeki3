class Cms::SiteAccessControl < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Site
  include Cms::Model::Auth::Site

  enum_ish :state, [:enabled, :disabled], predicate: true
  enum_ish :target_type, [:_system, :all, :directory], default: :_system
  enum_ish :ip_order, [:none, :allow, :deny], default: :none

  validates :site_id, :state, presence: true
  validates :target_location, presence: true,
                              format: { with: /\A[0-9A-Za-z@\.\-_\+\/]+\z/, message: :not_a_filename },
                              if: :target_type_directory?

  validate :validate_basic_auth
  validate :validate_ip

  def target_type_directory?
    target_type == 'directory'
  end

  def basic_auths
    basic_auths = basic_auth.to_s.split(/[\r\n]/)
                            .select { |ba| ba.present? && !ba.start_with?('#') }
    basic_auths.map { |ba|
      strs = ba.split(',', 2)
      { user: strs[0].to_s.strip, password: strs[1].to_s.strip }
    }.compact
  end

  def ips
    ip.to_s.split(/[\r\n]/)
      .select { |ip| ip.present? && !ip.start_with?('#') }
  end

  private

  def validate_basic_auth
    if basic_auths.any? { |ba| ba[:user].blank? || ba[:user] !~ /\A[a-zA-Z0-9_\-]+\z/ }
      errors.add(:base, "ユーザー名は英数字またはハイフン、アンダースコアで入力してください。")
    end
    if basic_auths.any? { |ba| ba[:password].blank? || !ba[:password].ascii_only? }
      errors.add(:base, "パスワードはASCII文字で入力してください。")
    end
  end

  def validate_ip
    ips.each do |ip|
      begin
        IPAddr.new(ip)
      rescue IPAddr::InvalidAddressError
        errors.add(:base, "#{ip}は正しいIPアドレスの形式ではありません。")
      end
    end
  end
end
