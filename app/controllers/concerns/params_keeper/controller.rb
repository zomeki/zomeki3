module ParamsKeeper::Controller
  extend ActiveSupport::Concern

  included do
    @@keep_params_keys = nil
  end

  def url_options_with_keep_params(options)
    if options.is_a?(Hash)
      keep_params(options)
    else
      options
    end
  end

  private

  def url_for(options = nil)
    options = url_options_with_keep_params(options)
    super
  end

  def keep_params(options)
    options.reverse_merge!(params.to_unsafe_h.deep_symbolize_keys.slice(*@@keep_params_keys)) if @@keep_params_keys
    options
  end

  class_methods do
    def keep_params(*keys)
      @@keep_params_keys = keys
    end
  end
end
