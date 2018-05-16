class Cms::Admin::Tool::LinkCheckController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:creator)
    return redirect_to(action: :index) if params[:reset]

    params[:limit] ||= '30'
  end

  def index
    logs = Cms::LinkCheckLog.where(site_id: Core.site.id)
    @logs = Cms::LinkCheckLogsFinder.new(logs)
                                    .search(params[:criteria])
                                    .order(:id)
                                    .preload(link_checkable: [:content, creator: :group])

    if params[:csv]
      csv = generate_csv(@logs)
      return send_data platform_encode(csv), type: 'text/csv', filename: "cms_link_check_logs_#{Time.now.to_i}.csv"
    end

    @logs = @logs.paginate(page: params[:page], per_page: params[:limit])

    if (@running = logs.where(checked: false).exists?)
      current = logs.where(checked: true).count
      total = logs.count
      flash.now[:notice] = "リンクチェックを実行中です。(#{current}/#{total}件)"
    end
  end

  private

  def generate_csv(logs)
    require 'csv'
    CSV.generate(force_quotes: true) do |csv|
      csv << ['ページタイトル', '作成者グループ', 'リンクテキスト', 'リンクURL', '結果', 'ステータス', '確認日時']
      logs.each do |log|
        csv << [log.title,
                log.link_checkable.try!(:creator).try!(:group).try!(:name),
                log.body,
                log.url,
                log.result_state_text(format: :mark),
                [log.status, log.reason].compact.join(' '),
                log.checked_at ? I18n.l(log.checked_at) : nil]
      end
    end
  end
end
