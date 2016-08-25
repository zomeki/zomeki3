module Concerns::Cms::DataFile::Queue
  extend ActiveSupport::Concern

  included do
    after_save :enqueue_publisher_after_save
  end

  def enqueue_publisher
    enqueue_bracketee_publisher
  end

  private

  def enqueue_publisher_after_save
    enqueue_publisher if enqueue_publisher?
  end

  def enqueue_publisher?
    return false if name.blank?
    true
  end

  def enqueue_bracketee_publisher
    return if bracketees.blank?

    owner_map = bracketees.map(&:owner).group_by { |owner| owner.class.name }

    %w(Cms::Layout Cms::Piece Cms::Node).each do |klass_name|
      if owner_map[klass_name].present?
        owner_map[klass_name].each do |item|
          item.enqueue_publisher
        end
      end
    end
  end
end
