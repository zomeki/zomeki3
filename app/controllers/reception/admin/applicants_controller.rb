class Reception::Admin::ApplicantsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return redirect_to(action: :index) if params[:reset_criteria]
    @content = Reception::Content::Course.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    @course = @content.courses.find(params[:course_id])
    @open = @course.opens.find(params[:open_id])

    @item = @open.applicants.find(params[:id]) if params[:id].present?
  end

  def index
    @items = @open.applicants.search_with_criteria(params[:criteria] || {}).order(:seq_no, :applied_at)
    return download_csv(@items) if params[:csv].present?

    @items = @items.paginate(page: params[:page], per_page: 50)
    _index @items
  end

  def show
    @item = @open.applicants.find(params[:id])
    _show @item
  end

  def new
    @item = @open.applicants.build(state: 'applied')
  end

  def create
    @item = @open.applicants.build(applicant_params)
    @item.applied_from = 'admin'
    @item.in_register_from_admin = true
    changes = @item.changes

    _create @item do
      send_received_mail(@item) if changes.dig(:state, 1) == 'received'
    end
  end

  def update
    @item = @open.applicants.find(params[:id])
    @item.attributes = applicant_params
    @item.in_register_from_admin = true
    changes = @item.changes

    _update @item do
      send_received_mail(@item) if changes.dig(:state, 1) == 'received'
    end
  end

  def destroy
    @item = @open.applicants.find(params[:id])
    _destroy @item
  end

  private

  def applicant_params
    params.require(:item).permit(
      :state, :name, :kana, :tel, :email, :remark, 
      :creator_attributes => [:id, :group_id, :user_id]
    )
  end

  def download_csv(items)
    require 'csv'
    csv_string = CSV.generate do |csv|
      csv << [
        Reception::Applicant.human_attribute_name(:seq_no),
        Reception::Applicant.human_attribute_name(:name),
        Reception::Applicant.human_attribute_name(:kana),
        Reception::Applicant.human_attribute_name(:tel),
        Reception::Applicant.human_attribute_name(:email),
        Reception::Applicant.human_attribute_name(:applied_at),
        Reception::Applicant.human_attribute_name(:applied_from),
        Reception::Applicant.human_attribute_name(:state)
      ]

      items.each do |item|
        csv << [
          item.seq_no,
          item.name,
          item.kana,
          item.tel,
          item.email,
          I18n.l(item.applied_at),
          item.applied_from_text,
          item.state_text
        ]
      end
    end

    csv_string = csv_string.encode(Encoding::WINDOWS_31J, invalid: :replace, undef: :replace)
    send_data csv_string, type: 'text/csv', filename: "applicants_#{Time.now.to_i}.csv"
  end

  def send_received_mail(item)
    return if @content.mail_from.blank?

    if @content.auto_reply? && item.email.present?
      Reception::Admin::Mailer.applicant_received(
        applicant: item,
        from: @content.mail_from,
        to: item.email
      ).deliver_now
    end
    if @content.mail_to.present?
      Reception::Admin::Mailer.applicant_received_notification(
        applicant: item,
        from: @content.mail_from,
        to: @content.mail_to
      ).deliver_now
    end
  end
end
