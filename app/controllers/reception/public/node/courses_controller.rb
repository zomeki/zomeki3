class Reception::Public::Node::CoursesController < Cms::Controller::Public::Base
  def pre_dispatch
    @node = Page.current_node
    @content = Reception::Content::Course.find(@node.content_id)
  end

  def index
    case @content.doc_list_style
    when 'all_categories'
      @category_types = @content.visible_category_types
      render 'all_categories'
    else
      @courses = @content.public_courses.order(sort_no: :asc, id: :asc)
    end
  end

  def show
    @course = @content.courses.find_by!(name: params[:name])

    Page.current_item = @course
    Page.title = @course.title
  end
end
