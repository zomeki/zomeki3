class GpArticle::Public::Node::CommentsController < Cms::Controller::Public::Base
  include SimpleCaptcha::ControllerHelpers

  def pre_dispatch
    if (organization_content = Page.current_node.content).kind_of?(Organization::Content::Group)
      return http_error(404) unless organization_content.article_related?
      @content = organization_content.related_article_content
    else
      @content = GpArticle::Content::Doc.find_by(id: Page.current_node.content.id)
    end

    return http_error(404) unless @content

    return http_error(404) unless @content.blog_functions[:comment]

    @doc = @content.public_docs.find_by(name: params[:name])
    return http_error(404) unless @doc

    @confirmation_required = false
  end

  def new
    @comment = @doc.comments.build
    render :new_mobile if Page.mobile?
  end

  def confirm
    if @confirmation_required
      @comment = @doc.comments.build(comment_params)
      render :new unless @comment.valid?
    else
      create
    end
  end

  def create
    @comment = @doc.comments.build(comment_params)

    return render(:new) if params[:edit_comment]

    @comment.remote_addr = request.remote_ip
    @comment.user_agent = request.user_agent
    @comment.state = (@content.blog_functions[:comment_open] ? GpArticle::Comment::STATE_OPTIONS.first
                                                             : GpArticle::Comment::STATE_OPTIONS.last).last

    if simple_captcha_valid?
      if @comment.save
        GpArticle::Public::Mailer.commented_notification(@comment).deliver_now if @content.blog_functions[:comment_notification_mail]
        redirect_to @doc.public_full_uri
      else
        render :new
      end
    else
      @comment.errors.add(:base, '画像と文字が一致しません。')
      if @confirmation_required
        render :confirm
      else
        render :new
      end
    end
  end

  def comment_params
    params.require(:comment).permit(:author_name, :author_email, :author_url, :body)
  end
end
