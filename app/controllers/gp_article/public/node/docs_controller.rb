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
    @docs = @content.public_docs_for_list.order(display_published_at: :desc, published_at: :desc)
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
      @dates = if @content.monthly_pagination?
        date = params[:date].present? ? "#{params[:date]}01".to_date : @content.published_first_day
        @first_day = @content.published_first_day.beginning_of_month
        [date.beginning_of_month, date.end_of_month]
      else
        date = params[:date].present? ? params[:date].to_date : @content.published_first_day
        @first_day = @content.published_first_day.beginning_of_week
        [date.beginning_of_week, date.end_of_week]
      end

      @prev_doc = @content.public_docs_for_list.order(display_published_at: :asc, published_at: :asc)
        .select([:display_published_at, :published_at])
        .where(GpArticle::Doc.arel_table[:display_published_at].gteq(@dates.last + 1.day)).first
      @next_doc = @content.public_docs_for_list.order(display_published_at: :desc, published_at: :desc)
        .select([:display_published_at, :published_at])
        .where(GpArticle::Doc.arel_table[:display_published_at].lt(@dates.first - 1.day)).first

      @docs = @docs.search_date_column(:display_published_at, 'between', @dates)
      return http_error(404) if params[:date].present? && @docs.blank?
    end

    @items = @docs.group_by { |doc| doc.display_published_at.try(:strftime, '%Y年%-m月%-d日') }
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

    paths = params[:path].split('/')
    basename = paths.last
    extname = params[:format]
    thumb = paths[0].to_sym if paths.size == 2

    if (file = @doc.files.find_by(name: "#{basename}.#{extname}"))
      mt = Rack::Mime.mime_type(".#{extname}")
      type, disposition = (mt =~ %r!^image/|^application/pdf$! ? [mt, 'inline'] : [mt, 'attachment'])
      disposition = 'attachment' if request.env['HTTP_USER_AGENT'] =~ /Android/
      send_file file.upload_path(type: thumb), type: type, filename: file.name, disposition: disposition
    else
      http_error(404)
    end
  end

  def qrcode
    @doc = public_or_preview_docs(id: params[:id], name: params[:name])
    return http_error(404) unless @doc
    return http_error(404) unless @doc.qrcode_visible?

    if ::Storage.exists?(@doc.qrcode_path)
      mt = Rack::Mime.mime_type(".png")
      disposition = request.env['HTTP_USER_AGENT'] =~ /Android/ ? 'attachment' : 'inline'
      send_file @doc.qrcode_path, :type => mt, :filename => 'qrcode.ping', :disposition => disposition
    else
      qrcode = Util::Qrcode.create_date(@doc.public_full_uri, @doc.qrcode_path)
      if qrcode
        mt = Rack::Mime.mime_type(".png")
        disposition = request.env['HTTP_USER_AGENT'] =~ /Android/ ? 'attachment' : 'inline'
        send_data qrcode, :type => mt, :filename => 'qrcode.ping', :disposition => disposition
      else
        http_error(404)
      end
    end
  end

  private

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
