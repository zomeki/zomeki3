class Cms::Controller::Public::Data < Cms::Controller::Public::Base
  skip_after_action :render_public_layout
end
