class Cms::Admin::Tool::ExportController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @item = Cms::Model::Tool::Export.new
    return unless request.post?

    @item.attributes = params.require(:item).permit(:concept_id, target: [:layout, :piece])
    return unless @item.valid?

    ## concept
    @concept = Cms::Concept.find_by(id: @item.concept_id)
    return unless @concept

    export  = {
      :layouts => [],
      :pieces  => []
    }

    ## layout
    if @item.target && @item.target[:layout]
      #export[:layouts] = @concept.layouts#.to_json
      @concept.layouts.each do |layout|
        data = {}
        data[:layout] = layout

        export[:layouts] << {:layout => data}
      end
    end

    ## piece
    export[:pieces] = []
    if @item.target && @item.target[:piece]
      #export[:pieces] << piece.to_json(:include => [:content])
      @concept.pieces.each do |piece|
        next if piece.model !~ /^Cms::/
        data = {}
        data[:piece]     = piece
        data[:settings]  = piece.settings
        if piece.content
          data[:content]          = piece.content
          data[:content_concepts] = piece.content.concept.ancestors.map(&:name)
        end

        if piece.model == "Cms::Link"
          data[:link_items] = Cms::PieceLinkItem.where(piece_id: piece.id).to_a
        end

        export[:pieces] << {:piece => data}
      end
      #export[:pieces] = @concept.pieces.to_json(:include => [:content])
    end

    filename = "export_#{@concept.name}_#{Time.now.to_i}.json"
    filename = filename.gsub(/[\/\<\>\|:"\?\*\\]/, '_') 
    send_data export.to_json, :type => 'application/json', :filename => filename

    #redirect_to(:action => :index)
  end
end
