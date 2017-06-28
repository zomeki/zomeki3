class Cms::ContentNodeValidator < ActiveModel::Validator
  def validate(record)
    unless record.content.public_node
      record.errors.add(:base, options[:message] || '公開ディレクトリが作成されていません。')
    end
  end
end
