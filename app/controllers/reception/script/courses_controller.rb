class Reception::Script::CoursesController < Cms::Controller::Script::Publication
  def self.publishable?
    false
  end
end
