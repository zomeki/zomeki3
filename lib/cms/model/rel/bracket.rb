module Cms::Model::Rel::Bracket
  extend ActiveSupport::Concern

  included do
    has_many :brackets, class_name: 'Cms::Bracket', dependent: :destroy, as: :owner
    after_save :save_brackets
  end

  def bracket_names
    names = body_with_bracket.to_s.scan(/\[\[(piece|text|file)\/([^\]]+)\]\]/)
    names.map { |n1, n2| "#{n1}/#{n2}" }.uniq
  end

  private

  def body_with_bracket
    if self.class.is_a?(Cms::Layout)
      "#{body}#{mobile_body}#{smart_phone_body}"
    else
      body
    end
  end

  def save_brackets
    brackets.destroy_all
    bracket_names.each do |name|
      brackets.create(name: name)
    end
  end
end
