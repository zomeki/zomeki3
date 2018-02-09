class Cms::RenderService < ApplicationService
  include Cms::Controller::Layout
  attr_accessor :params

  def initialize(site)
    self.params = {}
    @site = site
  end

  def render_public(path, options = {})
    render_public_as_string(path, options.merge(site: @site))
  end
end
