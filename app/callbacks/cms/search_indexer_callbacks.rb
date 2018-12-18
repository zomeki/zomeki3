class Cms::SearchIndexerCallbacks < ApplicationCallbacks
  def after_save(item)
    enqueue(item)
  end

  def before_destroy(item)
    enqueue(item)
  end

  def enqueue(item)
    return unless enqueue?(item)
    enqueue_self(item)
    enqueue_files(item)
  end

  private

  def enqueue?(item)
    Zomeki.config.application['cms.search_indexer'] && [item.state, item.state_before_last_save].include?('public')
  end

  def enqueue_self(item)
    Cms::SearchIndexer.register(item.site_id, item)
  end

  def enqueue_files(item)
    if item.respond_to?(:files) && item.files.klass == Sys::File
      Cms::SearchIndexer.register(item.site_id, item.files)
    end
  end
end
