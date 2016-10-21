class Rank::Admin::Content::SettingsController < Cms::Admin::Content::SettingsController
  include Rank::Controller::Rank

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
    get_access(@content, nil)
    redirect_to :action => :index
  end

  def makeup
    calc_access(@content)
    redirect_to :action => :index
  end
end
