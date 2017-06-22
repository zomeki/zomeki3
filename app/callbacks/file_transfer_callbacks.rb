class FileTransferCallbacks < ApplicationCallbacks
  def initialize(path_methods, recursive: false)
    @path_methods = Array(path_methods)
    @recursive = recursive
  end

  def after_save_files(item)
    enqueue(item) if enqueue?(item)
  end

  def after_remove_files(item)
    enqueue(item) if enqueue?(item)
  end

  def after_publish_files(item)
    enqueue(item) if enqueue?(item)
  end

  def after_close_files(item)
    enqueue(item) if enqueue?(item)
  end

  private

  def enqueue?(item)
    Zomeki.config.application['cms.file_transfer']
  end

  def enqueue(item)
    site = item.site

    path_methods = @path_methods.dup
    path_methods.reject! { |method| method.to_s =~ /smart_phone/ && !site.publish_for_smart_phone?(item) }

    paths = path_methods.map { |method| item.public_send(method) }.select(&:present?).uniq
    return if paths.blank?

    Cms::FileTransfer.register(site.id, paths, recursive: @recursive)
  end
end
