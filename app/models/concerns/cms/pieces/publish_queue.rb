module Cms::Pieces::PublishQueue
  extend ActiveSupport::Concern

  included do
    after_save :enqueue_publisher_callback, if: :changed?
    before_destroy :enqueue_publisher_callback
  end

  def enqueue_publisher
    register_bracketee_publiser
  end

  private

  def enqueue_publisher_callback
    enqueue_publisher if enqueue_publisher?
  end

  def enqueue_publisher?
    name.present?
  end

  def register_bracketee_publiser
    bracketees = Cms::Bracket.where(site_id: site_id, name: changed_bracket_names).all
    return if bracketees.blank?

    owner_map = bracketees.map(&:owner).group_by { |owner| owner.class.name }

    %w(Cms::Node Cms::Layout).each do |klass_name|
      if owner_map[klass_name].present?
        owner_map[klass_name].each do |item|
          item.enqueue_publisher
        end
      end
    end
  end

  def changed_bracket_names
    type = Cms::Lib::Bracket.bracket_type(self)
    names = [name, name_was].select(&:present?).uniq
    names.map { |name| "#{type}/#{name}" }
  end
end
