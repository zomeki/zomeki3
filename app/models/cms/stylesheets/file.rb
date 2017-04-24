class Cms::Stylesheets::File < Sys::Storage::File
  include Cms::Model::Auth::Concept
  include Cms::Model::Auth::Stylesheet

  def concept
    parent.try(:concept)
  end

  private

  def validate_mime_type
    return true
  end
end
