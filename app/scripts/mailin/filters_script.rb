class Mailin::FiltersScript < ParametersScript
  def exec
    contents = Mailin::Content::Filter.all
    contents = contents.in_site(::Script.site) if ::Script.site
    contents = contents.to_a.select { |c| c.execution_time?(::Script.options[:startup]) }
    return if contents.blank?

    contents.each do |content|
      pop(content)
    end
  end

  private

  def pop(content)
    require 'net/pop'

    apop = Net::POP3.APOP(content.mail_protocol_apop?).new(content.mail_host, content.mail_port)
    apop.start(content.mail_username, content.mail_password) do |pop|
      ::Script.total pop.n_mails
      pop.mails.each do |mail|
        ::Script.current
        if filter(content, mail.pop)
          ::Script.success
          mail.delete
        end
      end
    end
  end

  def filter(content, mail_source)
    mail = begin
             Mailin::MailProxy.new(Mail.new(mail_source))
           rescue => e
             error_log e
             nil
           end
    return false unless mail

    content.filters.each do |filter|
      if filter.match?(mail)
        return import(filter, mail)
      end
    end

    false
  end

  def import(filter, mail)
    begin
      Mailin::DocBuilderService.new(filter).build(mail)
    rescue => e
      error_log e
      return false
    end

    filter.update_columns(filtered_at: Time.now)
    return true
  end
end
