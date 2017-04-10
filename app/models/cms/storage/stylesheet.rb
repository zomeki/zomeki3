class Cms::Storage::Stylesheet < Sys::Storage::Entry
  include Cms::Model::Auth::Concept

  define_attribute_methods :concept_id
  set_callback :save, :before, :save_stylesheet
  set_callback :destroy, :before, :destroy_stylesheet

  def concept_id
    @concept_id
  end

  def concept_id=(val)
    concept_id_will_change! unless val == @concept_id
    @concept_id = val
  end

  def concept
    return @concept if defined? @concept
    cid = concept_id.presence || parent.try(:concept_id).presence
    @concept = Cms::Concept.find_by(id: cid) if cid.present?
  end

  def stylesheet
    @stylesheet ||= Cms::Stylesheet.find_by(site_id: site_id, path: path_from_themes_root) if path_from_themes_root.present?
  end

  def themes_root_path
    ::File.join(site_root_path, "public/_themes").to_s
  end

  def themes_root_path?
    path == themes_root_path
  end

  def path_from_themes_root
    return if path !~ /^#{themes_root_path}/
    path.sub(/^#{themes_root_path}/, '').sub(%r|^/|, '')
  end

  def public_themes_uri
    "/_themes/#{path_from_themes_root}"
  end

  def readable_themes?
    return false unless site
    Core.user.root? || (Core.user.sites.include?(site) && path =~ %r|^#{themes_root_path}|)
  end

  def readable?
    super && readable_themes?
  end

  def creatable?
    super && readable_themes?
  end

  def editable?
    super && readable_themes?
  end

  def deletable?
    super && readable_themes?
  end

  private

  def save_stylesheet
    if directory_entry?
      item = stylesheet || Cms::Stylesheet.new(site_id: site_id)
      item.concept_id = concept_id
      item.path = path_from_themes_root
      item.save
    end
  end

  def destroy_stylesheet
    stylesheet.destroy if directory_entry? && stylesheet
  end

  def validate_mime_type
    return true
  end

  class << self
    def from_path(path)
      item = super
      item.concept_id = item.stylesheet.try(:concept_id)
      item
    end
  end
end
