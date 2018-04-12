module Sys::Controller::Scaffold::Hold
  extend ActiveSupport::Concern

  def _hold(item)
    item.users_holds.where(user_id: Core.user.id, session_id: session.id).first_or_create

    if (holds = item.users_holds.where.not(session_id: session.id)).present?
      alerts = holds.map { |hold| "<li>#{hold.group_and_user_name}さんが#{hold.formatted_updated_at}から編集中です。</li>" }.join
      flash.now[:alert] = "<ul>#{alerts}</ul>".html_safe
    end
  end

  def _update(item, options = {}, &block)
    unless item.users_holds.where(user_id: Core.user.id, session_id: session.id).exists?
      last_editor = if item.editors.first
                      item.editors.first.group_and_user_name
                    else
                      '他のユーザー'
                    end
      flash.now[:alert] = "#{last_editor}さんが記事を編集したため、編集内容を反映できません。"
      return render :edit
    end

    super do
      block.call if block
      item.users_holds.delete_all
    end
  end
end
