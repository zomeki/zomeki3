class CommonMailer < ApplicationMailer
  def plain(options)
    @body_text = options[:body]
    mail from: options[:from],
         to: options[:to],
         subject: options[:subject]
  end
end