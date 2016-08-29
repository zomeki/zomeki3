module GpArticle::Model::Rel::Sns
  extend ActiveSupport::Concern

  included do
    attr_accessor :in_share_accounts
    after_save :save_share_accounts, if: 'in_share_accounts.present?'
  end

  def in_share_account_params
    return @in_share_account_params if defined? @in_share_account_params
    @in_share_account_params =
      if in_share_accounts.present?
        in_share_accounts
      else
        sns_accounts.map(&:id)
      end
  end

  private

  def save_share_accounts
    self.sns_account_ids = in_share_accounts.select(&:present?).map(&:to_i).uniq
  end
end
