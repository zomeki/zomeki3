module ActionController
  class Parameters < ActiveSupport::HashWithIndifferentAccess
    def to_s
      to_h.with_indifferent_access.to_yaml
    end
  end
end
