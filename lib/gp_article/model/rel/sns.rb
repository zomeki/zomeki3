module GpArticle::Model::Rel::Sns
  extend ActiveSupport::Concern

  included do
    after_save :save_share_accounts, if: -> { in_share_accounts.present? }
  end

  def in_share_accounts=(val)
    @in_share_accounts = val
  end

  def in_share_accounts
    @in_share_accounts ||= sns_accounts.map(&:id)
  end

  private

  def save_share_accounts
    self.sns_account_ids = in_share_accounts.select(&:present?).map(&:to_i).uniq
  end
end
