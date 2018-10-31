module Approval::Controller::Admin::Approval
  def _approve(item)
    if item.approvable?(Core.user)
      item.class.transaction do
        item.approve(Core.user) do |approval_request|
          send_approval_request_mail(item, approval_request: approval_request) unless approval_request.finished?
        end

        if item.approval_requests.all?(&:finished?)
          item.update_columns(state: (item.queued_tasks.where(name: 'publish').exists? ? 'prepared' : 'approved'),
                              recognized_at: Time.now)
          item.enqueue_tasks
          Sys::OperationLog.log(request, item: item)
          send_approved_notification_mail(item, approver: Core.user)
        end
      end

      yield if block_given?
      redirect_to url_for(action: :show), notice: '承認処理が完了しました。'
    else
      redirect_to url_for(action: :show), notice: '承認処理に失敗しました。'
    end
  end

  def _passback(item)
    if item.passbackable?(Core.user)
      item.class.transaction do
        item.passback(Core.user, comment: params[:comment])
        item.update_columns(state: 'draft')
      end

      send_passbacked_notification_mail(item, approver: Core.user, comment: params[:comment])

      yield if block_given?
      redirect_to url_for(action: :show), notice: '差し戻しが完了しました。'
    else
      redirect_to url_for(action: :show), notice: '差し戻しに失敗しました。'
    end
  end

  def _pullback(item)
    if item.pullbackable?(Core.user)
      item.class.transaction do
        item.pullback(comment: params[:comment])
        item.update_columns(state: 'draft')
      end

      send_pullbacked_notification_mail(item, comment: params[:comment])

      yield if block_given?
      redirect_to url_for(action: :show), notice: '引き戻しが完了しました。'
    else
      redirect_to url_for(action: :show), notice: '引き戻しに失敗しました。'
    end
  end

  private

  def send_approval_request_mail(item, approval_request: nil)
    approval_requests = approval_request ? [approval_request] : item.approval_requests
    approval_requests.each do |approval_request|
      requester = approval_request.requester
      approval_request.current_approvable_approvers.each do |approver|
        next if requester.email.blank? || approver.email.blank?
        Approval::Admin::Mailer.approval_request(from: requester,
                                                 to: approver,
                                                 item: item,
                                                 approval_request: approval_request).deliver_now
      end
    end
  end

  def send_approved_notification_mail(item, approver:)
    requesters = item.approval_requests.map(&:requester).uniq
    requesters.each do |requester|
      next if approver.email.blank? || requester.email.blank?
      Approval::Admin::Mailer.approved_notification(from: approver,
                                                    to: requester,
                                                    item: item).deliver_now
    end
  end

  def send_passbacked_notification_mail(item, approver:, comment:)
    requesters = item.approval_requests.map(&:requester).uniq
    requesters.each do |requester|
      next if approver.email.blank? || requester.email.blank?
      Approval::Admin::Mailer.passbacked_notification(from: approver,
                                                      to: requester,
                                                      item: item,
                                                      comment: comment).deliver_now
    end
  end

  def send_pullbacked_notification_mail(item, comment:)
    item.approval_requests.each do |approval_request|
      requester = approval_request.requester
      approval_request.current_approvers.each do |approver|
        next if approver.email.blank? || requester.email.blank?
        Approval::Admin::Mailer.pullbacked_notification(from: requester,
                                                        to: approver,
                                                        item: item,
                                                        comment: comment).deliver_now
      end
    end
  end
end
