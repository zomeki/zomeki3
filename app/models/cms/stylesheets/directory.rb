class Cms::Stylesheets::Directory < Sys::Storage::Directory
  include Cms::Model::Auth::Concept
  include Cms::Model::Auth::Stylesheet

  define_attribute_methods :concept_id
  attr_reader :concept_id

  after_initialize :set_concept_id
  before_save_files :save_stylesheet
  before_remove_files :destroy_stylesheet

  def concept_id=(val)
    concept_id_will_change! unless val == @concept_id
    @concept_id = val
  end

  def concept
    return @concept if defined? @concept
    @concept = concept_id.present? ? Cms::Concept.find_by(id: concept_id) : parent.try(:concept)
  end

  def stylesheet
    @stylesheet ||= Cms::Stylesheet.find_by(site_id: site_id, path: path_from_themes_root) if path_from_themes_root.present?
  end

  private

  def set_concept_id
    self.concept_id = stylesheet.try(:concept_id)
  end

  def save_stylesheet
    item = stylesheet || Cms::Stylesheet.new(site_id: site_id)
    item.concept_id = concept_id
    item.path = path_from_themes_root
    item.save
    return true
  end

  def destroy_stylesheet
    stylesheet.destroy if directory_entry? && stylesheet
    return true
  end
end
