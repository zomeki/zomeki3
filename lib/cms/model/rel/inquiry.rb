module Cms::Model::Rel::Inquiry
  extend ActiveSupport::Concern

  included do
    has_many :inquiries, -> { order(:id) }, class_name: 'Cms::Inquiry', dependent: :destroy, as: :inquirable
    accepts_nested_attributes_for :inquiries, allow_destroy: true, reject_if: :reject_inquiry
  end

  def build_default_inquiry(options = {})
    return if inquiries.present?

    if (g = options[:group])
      default_state = content && content.inquiry_default_state
      inquiries.build(state: default_state, group_id: g.id, tel: g.tel, fax: g.fax, email: g.email)
    else
      inquiries.build
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
