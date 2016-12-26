class Reception::Public::Mailer < ApplicationMailer
  def applicant_applied(applicant:, from:, to:)
    @content = applicant.content
    @course = applicant.course
    @applicant = applicant

    mail from: from, to: to, subject: "#{@course.title}（#{@content.site.name}）：お申込み"
  end

  def applicant_canceled(applicant:, from:, to:)
    @content = applicant.content
    @course = applicant.course
    @applicant = applicant

    mail from: from, to: to, subject: "#{@course.title}（#{@content.site.name}）：お申込みキャンセル"
  end
end
