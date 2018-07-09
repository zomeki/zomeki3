class Cms::Admin::ConceptsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    #return error_auth unless Core.user.has_auth?(:manager)
    return error_auth unless Core.user.has_auth?(:designer)#observe_field
    
    unless @parent = Cms::Concept.find_by(id: params[:parent])
      @parent = Cms::Concept.new(
        name:     'コンセプト',
        level_no: 0
      )
      @parent.id = 0
    end
  end
  
  def index
    @items = Core.site.concepts.to_tree

    _index @items
  end
  
  def show
    @item = Cms::Concept.find(params[:id])
    return error_auth unless @item.readable?
    _show @item
  end

  def new
    @item = Cms::Concept.new(
      parent_id: @parent.id,
      state:     'public',
      sort_no:   0
    )
  end
  
  def create
    @item = Cms::Concept.new(concept_params)
    @item.parent_id = 0 unless @item.parent_id
    @item.site_id   = Core.site.id
    @item.level_no  = @parent.level_no + 1
    _create @item
  end
  
  def update
    @item = Cms::Concept.find(params[:id])
    @item.attributes = concept_params
    @item.parent_id  = 0 unless @item.parent_id
    @item.level_no   = @parent.level_no + 1
    
    parent = Cms::Concept.find_by(id: @item.parent_id)
    @item.level_no = (parent ? parent.level_no + 1 : 1)
    
    _update @item do
      update_level_no
    end
  end
  
  def destroy
    @item = Cms::Concept.find(params[:id])
    _destroy @item do
      respond_to do |format|
        format.html { return redirect_to cms_concepts_path(@parent) }
      end
    end
  end
  
  def layouts(rendering = true)
    layouts = []

    concept = if params[:concept_id].to_i > 0
                Cms::Concept.find_by(id: params[:concept_id])
              elsif params[:parent].to_i > 0
                if node = Cms::Node.find_by(id: params[:parent])
                  node.inherited_concept
                end
              end

    concept.ancestors.each { |c| layouts += c.layouts } if concept

    layouts = layouts.collect{|i| ["#{i.concept.name} : #{i.title}", i.id]}
    layouts.unshift ["// 一覧を更新しました（#{layouts.size}件）", '']
    @layouts = layouts

    respond_to do |format|
      format.html { render layout: false }
    end
  end

  private

  def concept_params
    params.require(:item).permit(:name, :parent_id, :sort_no, :state, :creator_attributes => [:id, :group_id, :user_id])
  end

  def update_level_no
    @item.descendants.each do |child|
      child.update_columns(level_no: child.ancestors.size)
    end
  end
end
