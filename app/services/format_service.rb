class FormatService < ApplicationService
  include ActionView::Helpers
  include ERB::Util
  include ::ApplicationHelper
  include ::DateHelper

  attr_accessor :output_buffer
end
