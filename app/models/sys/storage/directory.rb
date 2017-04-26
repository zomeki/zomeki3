class Sys::Storage::Directory < Sys::Storage::Entry
  after_save_files :save_storage_files
  before_remove_files :destroy_storage_files

  validates :name, presence: true
  with_options if: -> { name.present? } do
    validates :name, format: { with: /\A[0-9A-Za-z@\.\-\_]+\z/, message: 'は半角英数字で入力してください。' }
    validates :name, format: { with: /\A[^_]/, message: '先頭に「_」を含むディレクトリは作成できません。' }
  end

  def descendants(items = [])
    items << self
    children.each { |child| child.descendants(items) }
    items
  end

  def save(options = {})
    super do
      if new_entry
        # new directory
        ::Storage.mkdir(path) unless ::Storage.exists?(path)
      else
        # move
        if path_changed?
          ::Storage.mv(path_was, path) if ::Storage.exists?(path_was) && !::Storage.exists?(path)
        end
      end
    end
  end

  def destroy
    super do
      ::Storage.rm_rf(path)
    end
  end

  private

  def set_defaults
    super
    self.entry_type = :directory
  end

  def save_storage_files
    if path_changed?
      files = Sys::StorageFile.arel_table
      Sys::StorageFile.where(files[:path].matches("#{path_was}/%"))
                      .replace_for_all(:path, "#{path_was}/", "#{path}/")
    end
  end

  def destroy_storage_files
    Sys::StorageFile.files_under_directory(path).destroy_all
  end
end
