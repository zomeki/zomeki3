class Cms::ContentNodeValidator < ActiveModel::Validator
  def validate(record)
    unless record.content.public_node
      record.errors.add(:base, options[:message] || 'コンテンツのディレクトリが公開されていません。')
    end
  end
end
