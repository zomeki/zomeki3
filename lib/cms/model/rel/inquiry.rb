module Cms::Model::Rel::Inquiry
  extend ActiveSupport::Concern

  included do
    has_many :inquiries, class_name: 'Cms::Inquiry', dependent: :destroy, as: :inquirable
    accepts_nested_attributes_for :inquiries, allow_destroy: true, reject_if: :reject_inquiry
  end

  def inquiry_states
    [['表示','visible'],['非表示','hidden']]
  end

  def build_default_inquiry(options = {})
    return if inquiries.present?

    if (g = options[:group] || Core.user_group)
      inquiries.build(state: default_inquiry_state, group_id: g.id, tel: g.tel, fax: g.fax, email: g.email)
    else
      inquiries.build
    end
  end

  def validate_inquiry
    return true if content && !content.inquiry_related?

    inquiries.each_with_index do |inquiry, i|
      next unless inquiry.visible?

      inquiry.errors.add(:tel, :onebyte_characters) if inquiry.tel.to_s !~/^[ -~｡-ﾟ]*$/
      inquiry.errors.add(:fax, :onebyte_characters) if inquiry.fax.to_s !~/^[ -~｡-ﾟ]*$/
      inquiry.errors.add(:email, :invalid) if inquiry.email.to_s !~/^[ -~｡-ﾟ]*$/
    end

    inquiries.each do |inquiry|
      inquiry.errors.each do |key|
        errors.add(:"inquiries/#{key}", inquiry.errors[key]) unless errors.include?(:"inquiries/#{key}")
      end
    end
  end

  def default_inquiry_state
    if content && content.inquiry_extra_values
      content.inquiry_extra_values[:state]
    else
      'hidden'
    end
  end

  def inquiry_title
    if content && content.inquiry_extra_values
      content.inquiry_extra_values[:inquiry_title].to_s
    else
      'お問い合わせ'
    end
  end

  def inquiry_style
    if content && content.inquiry_extra_values
      content.inquiry_extra_values[:inquiry_style].to_s
    else
      '@name@@address@@tel@@fax@@email_link@'
    end
  end

  private

  def reject_inquiry(attributes)
    exists = attributes[:id].present?
    invalid = attributes[:group_id].blank?
    attributes.merge!(_destroy: 1) if exists && invalid
    !exists && invalid
  end
end
