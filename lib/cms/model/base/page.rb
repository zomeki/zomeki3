module Cms::Model::Base::Page
  extend ActiveSupport::Concern

  included do
    include Cms::Model::Base::Page::Publisher
    include Cms::Model::Base::Page::TalkTask
  end
end
