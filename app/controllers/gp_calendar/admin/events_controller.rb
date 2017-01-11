class GpCalendar::Admin::EventsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  include Cms::ApiGpCalendar

  def pre_dispatch
    return error_auth unless @content = GpCalendar::Content::Event.find_by(id: params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    return redirect_to url_for(action: :index) if params[:reset_criteria]
#    return redirect_to(request.env['REQUEST_PATH']) if params[:reset_criteria]
  end

  def index
    require 'will_paginate/array'

    criteria = params[:criteria] || {}
    criteria[:imported] = params[:imported] || 'no'
    @items = GpCalendar::Event.content_and_criteria(@content, criteria).to_a

    criteria[:date] = Date.parse(criteria[:date]) rescue nil
    @events = GpCalendar::Holiday.content_and_criteria(@content, criteria).where(kind: :event)
    @events.each do |event|
      event.started_on = Time.now.year if event.repeat?
      @items << event if event.started_on
    end

    case criteria[:order]
      when 'created_at_desc'
        @items.sort! {|a, b| a.created_at <=> b.created_at}
      when 'created_at_asc'
        @items.sort! {|a, b| b.created_at <=> a.created_at}
      else
        @items.sort! {|a, b| (a.started_on <=> b.started_on) * -1}
    end

    @items = @items.to_a.paginate(page: params[:page], per_page: 50)

    _index @items
  end

  def show
    @item = @content.events.find(params[:id])
    _show @item
  end

  def new
    @item = @content.events.build
  end

  def create
    @item = @content.events.build(event_params)
    _create(@item) do
      gp_calendar_sync_events_export(doc_or_event: @item) if @content.event_sync_export?
    end
  end

  def update
    @item = @content.events.find(params[:id])
    @item.attributes = event_params
    location = @item.sync_source_host ? gp_calendar_events_path(imported: 'yes') : gp_calendar_events_path
    _update(@item, location: location) do
      gp_calendar_sync_events_export(doc_or_event: @item) if @content.event_sync_export?
    end
  end

  def destroy
    @item = @content.events.find(params[:id])
    _destroy(@item) do
      gp_calendar_sync_events_export(doc_or_event: @item) if @content.event_sync_export?
    end
  end

  private

  def event_params
    params.require(:item).permit(
      :description, :ended_on, :href, :started_on, :state, :target, :title, :note, :in_tmp_id,
      :creator_attributes => [:id, :group_id, :user_id]
    ).tap do |permitted|
      [:in_category_ids].each do |key|
        permitted[key] = params[:item][key].to_unsafe_h if params[:item][key]
      end
    end
  end
end
