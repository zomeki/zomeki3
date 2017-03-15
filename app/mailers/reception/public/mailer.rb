class Reception::Public::Mailer < ApplicationMailer
  def applicant_applied(applicant:, from:, to:)
    @content = applicant.content
    @course = applicant.course
    @applicant = applicant

    mail from: from, to: to, subject: "#{@course.title}（#{@content.site.name}）：お申込み"
  end

  def applicant_applied_notification(applicant:, from:, to:)
    @content = applicant.content
    @course = applicant.course
    @applicant = applicant
    @applicant_admin_uri = applicant_admin_uri(@applicant)

    mail from: from, to: to, subject: "#{@course.title}（#{@content.site.name}）：お申込み通知メール"
  end

  def applicant_canceled(applicant:, from:, to:)
    @content = applicant.content
    @course = applicant.course
    @applicant = applicant

    mail from: from, to: to, subject: "#{@course.title}（#{@content.site.name}）：お申込みキャンセル"
  end

  def applicant_canceled_notification(applicant:, from:, to:)
    @content = applicant.content
    @course = applicant.course
    @applicant = applicant
    @applicant_admin_uri = applicant_admin_uri(@applicant)

    mail from: from, to: to, subject: "#{@course.title}（#{@content.site.name}）：お申込みキャンセル通知メール"
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
