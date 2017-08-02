module ParamsKeeper::Helper
  def url_for(options = nil)
    options = controller.url_options_with_keep_params(options) if controller.respond_to?(:url_options_with_keep_params)
    super
  end
end
