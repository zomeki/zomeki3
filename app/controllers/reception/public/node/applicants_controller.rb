class Reception::Public::Node::ApplicantsController < Cms::Controller::Public::Base
  before_action :check_applicable, only: [:new, :create]

  def pre_dispatch
    @node = Page.current_node
    @content = Reception::Content::Course.find(@node.content_id)
    @course = @content.courses.find_by!(name: params[:name])

    Page.current_item = @course
    Page.title = @course.title
  end

  def new
    @applicant = Reception::Applicant.new(open_id: params[:open_id])
  end

  def create
    @applicant = Reception::Applicant.new(applicant_params)
    @applicant.applied_from = 'public'
    @applicant.state = 'applied'
    @applicant.remote_addr = request.remote_ip
    @applicant.user_agent = request.user_agent

    case
    when params[:commit]
      if @applicant.save(context: :public_applicant)
        send_applied_mail(@applicant)
        render :finish
      else
        render :new
      end
    when params[:back]
      render :new
    else
      if @applicant.valid?(:public_applicant)
        render :confirm
      else
        render :new
      end
    end
  end

  def cancel
    @applicant = @course.applicants.find_by(token: params[:token])
    return http_error(404) if @applicant.nil? || !@applicant.cancelable?
    return render :cancel if request.get?

    if @applicant.seq_no != params[:seq_no].to_i
      @applicant.errors.add(:base, '受付番号を照会できませんでした。受付番号をお確かめください。')
      return render :cancel
    end

    @applicant.state = 'canceled'

    case
    when params[:commit]
      if @applicant.save(validate: false)
        send_canceled_mail(@applicant)
        render :cancel_finish
      else
        render :cancel
      end
    else
      render :cancel_confirm
    end
  end

  private

  def applicant_params
    params.require(:item).permit(
      :open_id, :name, :kana, :tel, :email, :email_confirmation, :remark
    )
  end

  def check_applicable
    return http_error(404) unless @course.applicable?
  end

  def send_applied_mail(applicant)
    return if @content.mail_from.blank?

    mail_tos = []
    mail_tos << @content.mail_to if @content.mail_to.present?
    mail_tos << applicant.email if @content.auto_reply? && applicant.email.present?

    mail_tos.each do |mail_to|
      Reception::Public::Mailer.applicant_applied(
        applicant: applicant,
        from: @content.mail_from,
        to: mail_to
      ).deliver_now
    end
  end

  def send_canceled_mail(applicant)
    return if @content.mail_from.blank?

    mail_tos = []
    mail_tos << @content.mail_to if @content.mail_to.present?
    mail_tos << applicant.email if @content.auto_reply? && applicant.email.present?

    mail_tos.each do |mail_to|
      Reception::Public::Mailer.applicant_canceled(
        applicant: applicant,
        from: @content.mail_from,
        to: mail_to
      ).deliver_now
    end
  end
end
