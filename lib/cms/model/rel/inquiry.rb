module Cms::Model::Rel::Inquiry
  extend ActiveSupport::Concern

  included do
    has_many :inquiries, class_name: 'Cms::Inquiry', dependent: :destroy, as: :inquirable
    accepts_nested_attributes_for :inquiries, allow_destroy: true, reject_if: :reject_inquiry
  end

  def inquiry_states
    [['表示','visible'],['非表示','hidden']]
  end

  def build_default_inquiry(params = {})
    if inquiries.size == 0
      if g =  Core.user.group
        inquiries.build({:state => default_inquiry_state, :group_id => g.id, :tel => g.tel, :fax => g.fax, :email => g.email}.merge(params))
      else
        inquiries.build(params)
      end
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

  def inquiry_display_fields
    if content && content.inquiry_extra_values
      content.inquiry_extra_values[:display_fields]
    else
      ['group_id', 'charge', 'address', 'tel', 'fax', 'email', 'note']
    end
  end

  def inquiry_display_field?(name)
    inquiry_display_fields.include?(name.to_s)
  end

  def set_inquiry_group
    return if (group_id = creator.try(:group_id)).blank?
    return if group_id.to_i.in?(inquiries.map(&:group_id))
    inquiries.build(group_id: group_id)
  end

  private

  def reject_inquiry(attributes)
    exists = attributes[:id].present?
    invalid = attributes[:group_id].blank?
    attributes.merge!(_destroy: 1) if exists && invalid
    !exists && invalid
  end
end
