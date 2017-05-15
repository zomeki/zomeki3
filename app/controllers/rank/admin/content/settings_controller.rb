class Rank::Admin::Content::SettingsController < Cms::Admin::Content::SettingsController
  def model
    Rank::Content::Setting
  end

  def update
    @item = model.config(@content, params[:id])
    @item.value = params[:item][:value]
    @item.extra_values = params[:item][:extra_values] if params[:item][:extra_values]
    _update @item do
      if @item.name == 'google_oauth' && @item.value.blank?
        return redirect_to action: :edit 
      end
    end
  end

  def import
    begin
      result = Rank::RankFetchJob.perform_now(@content)
      flash[:notice] = if result
                         "一括取込が完了しました。"
                       else
                         "一括取込に失敗しました。トラッキングIDとOAuthの設定を確認してください。"
                       end
    rescue => e
      flash[:notice] = "一括取込に失敗しました。（#{e}）"
    end
    redirect_to action: :index
  end

  def makeup
    Rank::RankTotalJob.perform_now(@content)
    flash[:notice] = "集計が完了しました。"
    redirect_to action: :index
  end
end
