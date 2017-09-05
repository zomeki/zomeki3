class Mailin::MailProxy
  def initialize(mail)
    @mail = mail
  end

  def method_missing(name)
    if @mail.respond_to?(name)
      @mail.send(name)
    else
      super
    end
  end

  def inline_contents
    @inline_contents ||= collect_inline_contents(@mail)
  end

  private

  def collect_inline_contents(part, contents = [])
    if part.mime_type == 'message/rfc822'
      mail = Mail.new(part.decoded)
      collect_inline_contents(mail, contents)
    elsif part.mime_type == 'multipart/alternative'
      if part.html_part.present?
        contents << InlineContent.new(part: part, body: decode_html_part(part.html_part))
      elsif part.text_part.present?
        contents << InlineContent.new(part: part, body: decode_text_part(part.text_part))
      end
    elsif part.main_type == 'multipart'
      part.parts.each { |p| collect_inline_contents(p, contents) }
    elsif !part.attachment? && part.main_type == 'text'
      contents << InlineContent.new(part: part, body: decode_text_part(part))
    end
    contents
  end

  def decode_text_part(part)
    decode_part(part)
  end

  def decode_html_part(part)
    html = decode_part(part)
    html = Sanitize.document(html, Sanitize::Config::RELAXED)
    Nokogiri::HTML(html).css('body').inner_html
  end

  def decode_part(part)
    part.decoded.force_encoding('utf-8')
  rescue => e
    error_log e
    part.raw_source.force_encoding('utf-8')
  end

  class InlineContent
    include ActiveModel::Model
    attr_accessor :part, :body

    def to_html
      if part.mime_type == 'text/html'
        body
      else
        body.gsub(/\r\n|\r|\n/, '<br />')
      end
    end
  end
end
