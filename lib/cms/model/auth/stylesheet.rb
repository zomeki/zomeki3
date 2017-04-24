module Cms::Model::Auth::Stylesheet
  def readable?
    readable_dir?
  end

  def creatable?
    readable_dir? && super
  end

  def editable?
    readable_dir? && super
  end

  def deletable?
    readable_dir? && super
  end

  private

  def readable_dir?
    return false unless site
    Core.user.root? || (Core.user.sites.include?(site) && path =~ %r|^#{site.public_path}|)
  end
end
