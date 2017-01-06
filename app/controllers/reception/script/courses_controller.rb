class Reception::Script::CoursesController < Cms::Controller::Script::Publication
  def publish
    render plain: 'OK'
  end
end
