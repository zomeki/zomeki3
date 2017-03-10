require 'will_paginate/array'

class GpArticle::Public::Node::DocsController < Cms::Controller::Public::Base
  include GpArticle::Controller::Feed
  skip_after_action :render_public_layout, :only => [:file_content, :qrcode]

  def pre_dispatch
    if (organization_content = Page.current_node.content).kind_of?(Organization::Content::Group)
      return http_error(404) unless organization_content.article_related?
      @group = organization_content.find_group_by_path_from_root(params[:group_names])
      return http_error(404) unless @group
      @content = organization_content.related_article_content
    else
      @content = GpArticle::Content::Doc.find_by(id: Page.current_node.content.id)
      # Block if organization relation available
      if (organization_content = @content.organization_content_group) &&
          organization_content.article_related? &&
          organization_content.related_article_content == @content
        return http_error(404)
      end
    end

    return http_error(404) unless @content
  end

  def index
    @docs = @content.public_docs_for_list.order(@content.docs_order_as_hash)
    if params[:format].in?(['rss', 'atom'])
      @docs = @docs.display_published_after(@content.feed_docs_period.to_i.days.ago) if @content.feed_docs_period.present?
      @docs = @docs.paginate(page: params[:page], per_page: @content.feed_docs_number)
      return render_feed(@docs)
    end
    @docs = @docs.preload_assocs(:public_node_ancestors_assocs, :public_index_assocs)

    if @content.simple_pagination?
      @docs = @docs.paginate(page: params[:page], per_page: @content.doc_list_number)
      return http_error(404) if @docs.current_page > @docs.total_pages
    else
      @page_info = DatePaginationQuery.new(@docs,
                                           page_style: @content.doc_list_pagination,
                                           column: @content.docs_order_column,
                                           direction: @content.docs_order_direction,
                                           current_date: current_date).page_info

      @docs = @docs.search_date_column(@content.docs_order_column, 'between', @page_info[:current_dates])
      return http_error(404) if params[:date].present? && @docs.blank?
    end

    @items = @docs.group_by { |doc| doc[@content.docs_order_column].try(:strftime, @content.date_style) }
    render :index_mobile if Page.mobile?
  end

  def show
    params[:filename_base], params[:format] = 'index', 'html' unless params[:filename_base]

    @item = public_or_preview_docs(id: params[:id], name: params[:name])
    return http_error(404) if @item.nil? || @item.filename_base != params[:filename_base]
    if @group
      return http_error(404) unless @item.creator.group == @group.sys_group
    end
    return http_error(404) if @item.external_link?
    Page.current_item = @item
    Page.title = unless Page.mobile?
                   @item.title
                 else
                   @item.mobile_title.presence || @item.title
                 end
  end

  def file_content
    @doc = public_or_preview_docs(id: params[:id], name: params[:name])
    return http_error(404) unless @doc
    if @group
      return http_error(404) unless @doc.creator.group == @group.sys_group
    end

    params[:file] = File.basename(params[:path])
    params[:type] = :thumb if params[:path] =~ /(\/|^)thumb\//

    file = @doc.files.find_by!(name: "#{params[:file]}.#{params[:format]}")
    send_file file.upload_path(type: params[:type]), filename: file.name
  end

  def qrcode
    @doc = public_or_preview_docs(id: params[:id], name: params[:name])
    return http_error(404) unless @doc
    return http_error(404) unless @doc.qrcode_visible?

    if ::Storage.exists?(@doc.qrcode_path)
      send_file @doc.qrcode_path, filename: 'qrcode.png'
    else
      qrcode = Util::Qrcode.create_date(@doc.public_full_uri, @doc.qrcode_path)
      if qrcode
        send_data qrcode, filename: 'qrcode.png'
      else
        http_error(404)
      end
    end
  end

  private

  def current_date
    if params[:date].present?
      params[:date].size == 6 ? "#{params[:date]}01".to_time : params[:date].to_time
    else
      nil
    end
  end

  def public_or_preview_docs(id: nil, name: nil)
    unless Core.mode == 'preview'
      @content.public_docs.find_by(name: name)
    else
      if Core.publish
        case
        when id
          nil
        when name
          @content.preview_docs.find_by(name: name)
        end
      else
        case
        when id
          @content.all_docs.find_by(id: id)
        when name
          @content.public_docs.find_by(name: name) || @content.preview_docs.find_by(name: name)
        end
      end
    end
  end
end
