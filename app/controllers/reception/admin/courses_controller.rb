class Reception::Admin::CoursesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return redirect_to(action: :index) if params[:reset_criteria]
    @content = Reception::Content::Course.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)

    @item = @content.courses.find(params[:id]) if params[:id].present?
  end

  def index
    @items = @content.courses.search_with_criteria(params[:criteria] || {})
                     .with_target(params[:target])
                     .order(id: :asc)
    return download_csv(@items) if params[:csv].present?

    @items = @items.paginate(page: params[:page], per_page: 30)
    _index @items
  end

  def show
    _show @item
  end

  def new
    @item = @content.courses.build

    if @content.default_category
      @item.in_category_ids = { @content.default_category.category_type_id.to_s => [@content.default_category.id.to_s] }
    end
  end

  def create
    @item = @content.courses.build(course_params)
    @item.state = params[:commit_public].present? ? 'public' : 'draft'
    _create @item
  end

  def update
    @tests = course_params
    if @tests[:fee].present?
      @tests[:fee].delete!(",")
    end
    @item.attributes = @tests
    @item.state = params[:commit_public].present? ? 'public' : 'draft'
    _update @item
  end

  def destroy
    _destroy @item
  end

  def publish(item)
    item.state = 'public'
    _update item
  end

  def close(item)
    item.state = 'closed'
    _update item
  end

  private

  def course_params
    params.require(:item).permit(
      :name, :title, :subtitle, :body, :capacity, :fee, :fee_remark, :remark, :description, :sort_no, :in_tmp_id,
      :creator_attributes => [:id, :group_id, :user_id]
    ).tap do |permitted|
      [:in_file_names, :in_category_ids].each do |key|
        permitted[key] = params[:item][key].to_unsafe_h if params[:item][key]
      end
    end
  end

  def download_csv(items)
    require 'csv'
    csv_string = CSV.generate do |csv|
      csv << [
        Reception::Course.human_attribute_name(:title),
        Reception::Open.human_attribute_name(:open_on),
        Reception::Course.human_attribute_name(:capacity),
        Reception::Open.human_attribute_name(:applicants_count),
      ]

      items.each do |item|
        first_open = item.opens.first
        csv << [
          item.title,
          first_open && first_open.open_on ? I18n.l(first_open.open_on) : '',
          item.capacity,
          first_open ? first_open.applicants.size : ''
        ]
        item.opens.drop(1).each do |open|
          csv << [
            '',
            open.open_on ? I18n.l(open.open_on) : '',
            '',
            open.applicants.size
          ]
        end
      end
    end

    csv_string = csv_string.encode(Encoding::WINDOWS_31J, invalid: :replace, undef: :replace)
    send_data csv_string, type: 'text/csv', filename: "courses_#{Time.now.to_i}.csv"
  end
end
