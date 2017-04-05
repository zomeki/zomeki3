class Cms::Public::Api::AuthenticityTokenController < Cms::Controller::Public::Api
  def pre_dispatch
  end

  def index
    render json: { authenticity_token: form_authenticity_token }
  end
end
