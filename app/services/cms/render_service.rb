class Cms::RenderService < ApplicationService
  include Cms::Controller::Layout
  attr_accessor :params

  def initialize(site)
    self.params = {}
    @site = site
  end

  def render_public(path, agent_type: :pc)
    render_public_as_string(path, site: @site, agent_type: agent_type)
  end
end
