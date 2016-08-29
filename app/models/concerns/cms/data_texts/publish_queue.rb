module Cms::DataTexts::PublishQueue
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
    name.present?
  end

  def register_bracketee_publisher
    bracketees = Cms::Bracket.where(site_id: site_id, name: changed_bracket_names).all
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

  def changed_bracket_names
    type = Cms::Lib::Bracket.bracket_type(self)
    names = [name, name_was].select(&:present?).uniq
    names.map { |name| "#{type}/#{name}" }
  end
end
