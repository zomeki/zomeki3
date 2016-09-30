module GpArticle::Model::Rel::Tag
  extend ActiveSupport::Concern

  included do
    after_save :save_tags, if: -> { defined? @in_raw_tags }
  end

  def raw_tags=(new_raw_tags)
    @in_raw_tags = new_raw_tags
    super(@in_raw_tags)
  end

  def save_tags
    return tags.clear unless content.tag_content_tag

    all_tags = content.tag_content_tag.tags
    return tags.clear if raw_tags.blank?

    self.tags = Tag::Tag.split_raw_string(raw_tags.to_s).map do |word|
        all_tags.where(word: word).first || all_tags.create(word: word)
      end
    self.tags.each {|t| t.update_last_tagged_at }

    all_tags.each {|t| t.destroy if t.public_docs.empty? }
  end
end
