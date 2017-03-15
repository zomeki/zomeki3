class Reception::Public::Node::ApplicantsController < Cms::Controller::Public::Base
  before_action :check_applicable, only: [:index]

  def pre_dispatch
    @node = Page.current_node
    @content = Reception::Content::Course.find(@node.content_id)
    @course = @content.courses.find_by!(name: params[:name])

    Page.current_item = @course
    Page.title = @course.title
  end

  def index
    @applicant = Reception::Applicant.new(open_id: params[:open_id])
    return render :index if request.get?

    @applicant.attributes = applicant_params
    @applicant.applied_from = 'public'
    @applicant.state = Zomeki.config.application['sys.type'] == 'web' ? 'tmp_applied' : 'applied'
    @applicant.remote_addr = request.remote_ip
    @applicant.user_agent = request.user_agent
    @applicant.in_register_from_public = true

    case
    when params[:commit]
      if @applicant.save
        send_applied_mail(@applicant)
        render :finish
      else
        render :index
      end
    when params[:back]
      render :index
    else
      if @applicant.valid?
        render :confirm
      else
        render :index
      end
    end
  end

  def cancel
    @token = @course.applicant_tokens.find_by(token: params[:token])
    return http_error(404) if @token.nil? || !@token.cancelable?
    return render :cancel if request.get?

    if @token.seq_no != params[:seq_no].to_i
      @token.errors.add(:base, '受付番号を照会できませんでした。受付番号をお確かめください。')
      return render :cancel
    end

    case
    when params[:commit]
      applicant = @course.applicants.where(token: @token.token).first_or_initialize
      applicant.attributes = @token.attributes.slice('open_id', 'seq_no')
      applicant.state = Zomeki.config.application['sys.type'] == 'web' ? 'tmp_canceled' : 'canceled'
      if applicant.save(validate: false)
        send_canceled_mail(applicant)
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

    if @content.auto_reply? && applicant.email.present?
      Reception::Public::Mailer.applicant_applied(
        applicant: applicant,
        from: @content.mail_from,
        to: applicant.email
      ).deliver_now
    end
    if @content.mail_to.present?
      Reception::Public::Mailer.applicant_applied_notification(
        applicant: applicant,
        from: @content.mail_from,
        to: @content.mail_to
      ).deliver_now
    end
  end

  def send_canceled_mail(applicant)
    return if @content.mail_from.blank?

    if @content.auto_reply? && applicant.email.present?
      Reception::Public::Mailer.applicant_canceled(
        applicant: applicant,
        from: @content.mail_from,
        to: applicant.email
      ).deliver_now
    end
    if @content.mail_to.present?
      Reception::Public::Mailer.applicant_canceled_notification(
        applicant: applicant,
        from: @content.mail_from,
        to: @content.mail_to
      ).deliver_now
    end
  end
end
