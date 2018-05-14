module ApplicationHelper
  ## nl2br
  def br(str)
    str.to_s.gsub(/\r\n|\r|\n/, '<br />')
  end

  ## nl2br and escape
  def hbr(str)
    str = html_escape(str)
    str.gsub(/\r\n|\r|\n/, '<br />').html_safe
  end

  # I18n.localize
  def l(object, options = {})
    super(object, options) if object
  end

  def menu_header(*texts, with_action_name: true)
    header = texts.compact.join(' ：  ')
    header << I18n.t("actions.#{action_name}", default: '') if with_action_name
    header
  end
end
