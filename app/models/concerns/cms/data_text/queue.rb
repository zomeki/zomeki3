module Concerns::Cms::DataText::Queue
  extend ActiveSupport::Concern

  included do
    after_save :register_publisher_callback, if: :changed?
    before_destroy :register_publisher_callback
  end

  def register_publisher
    register_bracketee_publisher
  end

  private

  def register_publisher_callback
    register_publisher if register_publisher?
  end

  def register_publisher?
    return false unless Core.mode_system?
    return false if name.blank?
    true
  end

  def register_bracketee_publisher
    return if bracketees.blank?

    owner_map = bracketees.map(&:owner).group_by { |owner| owner.class.name }

    %w(Cms::Layout Cms::Piece Cms::Node).each do |klass_name|
      if owner_map[klass_name].present?
        owner_map[klass_name].each do |item|
          item.register_publisher
        end
      end
    end
  end
end
