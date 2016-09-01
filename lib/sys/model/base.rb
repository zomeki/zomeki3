module Sys::Model::Base
  extend ActiveSupport::Concern
  include Sys::Model::Scope
  include Sys::Model::Preload

  included do
    self.table_name = self.to_s.underscore.gsub('/', '_').downcase.pluralize
  end

  def locale(name)
    label = I18n.t name, :scope => [:activerecord, :attributes, self.class.to_s.underscore]
    label =~ /^translation missing:/ ? name.to_s.humanize : label
  end
end
