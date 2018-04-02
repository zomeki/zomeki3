module Survey::Controller::Public::Scoping
  extend ActiveSupport::Concern

  included do
    around_action :set_survey_public_scoping
  end

  private

  def set_survey_public_scoping
    if Core.mode == 'preview' && Page.preview_at
      Cms::PreviewItemsFinder.new(Survey::Form, Core.user).search(Page.preview_at).scoping { yield }
    else
      Survey::Form.public_state.scoping { yield }
    end
  end
end
