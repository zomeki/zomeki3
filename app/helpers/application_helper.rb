module ApplicationHelper
  ## nl2br
  def br(str)
    str.gsub(/\r\n|\r|\n/, '<br />')
  end

  ## nl2br and escape
  def hbr(str)
    str = html_escape(str)
    str.gsub(/\r\n|\r|\n/, '<br />').html_safe
  end

  ## safe calling
  def safe(alt = nil, &block)
    begin
      yield
#    rescue PassiveRecord::RecordNotFound => e
    rescue NoMethodError => e
      # nil判定を追加
      #if e.respond_to? :args and (e.args.nil? or (!e.args.blank? and e.args.first.nil?))
        alt
      #else
        # 原因がnilクラスへのアクセスでない場合は例外スロー
      #  raise
      #end
    end
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
