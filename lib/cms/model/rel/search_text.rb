module Cms::Model::Rel::SearchText
  extend ActiveSupport::Concern

  included do
    has_many :search_texts, class_name: 'Cms::SearchText', dependent: :destroy, as: :searchable
    after_save :save_search_texts
  end

  def rebuild_search_texts
    if save_search_texts
      Cms::SearchIndexerCallbacks.new.enqueue(self)
    end
  end

  private

  def save_search_texts
    return unless Zomeki.config.application['cms.search_indexer']

    renderer = Cms::BracketRenderService.new(site, inherited_concept)

    self.class.fts_columns.each do |column|
      st = search_texts.detect { |s| s.searchable_column == column.name } || search_texts.build(searchable_column: column.name)
      st.body = renderer.render_data_texts_and_files(read_attribute(column.name).to_s)
      st.save
    end

    search_texts.any? { |st| st.saved_changes.present? }
  end
end
