class Reception::Admin::Mailer < ApplicationMailer
  def applicant_received(applicant:, from:, to:)
    @content = applicant.content
    @course = applicant.course
    @applicant = applicant

    mail from: from, to: to, subject: "#{@course.title}（#{@content.site.name}）：お申込み受付完了"
  end

  def applicant_received_notification(applicant:, from:, to:)
    @content = applicant.content
    @course = applicant.course
    @applicant = applicant
    @applicant_admin_uri = applicant_admin_uri(@applicant)

    mail from: from, to: to, subject: "#{@course.title}（#{@content.site.name}）：お申込み受付完了通知メール"
  end

  private

  def applicant_admin_uri(applicant)
    reception_course_open_applicant_url(
      host: applicant.content.site.main_admin_uri.sub(/\/+$/, ''),
      content: applicant.content,
      concept: applicant.content.concept_id,
      course_id: applicant.course.id,
      open_id: applicant.open.id,
      id: applicant.id
    )
  end
end
