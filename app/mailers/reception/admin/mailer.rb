class Reception::Admin::Mailer < ApplicationMailer
  def applicant_received(applicant:, from:, to:)
    @content = applicant.content
    @course = applicant.course
    @applicant = applicant

    mail from: from, to: to, subject: "#{@course.title}（#{@content.site.name}）：お申込み受付完了"
  end
end
