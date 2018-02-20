class Cms::Tasks::Site::Backupper
  def initialize(site, dir:)
    @site = site
    @dir = dir
    @models = Cms::Tasks::Site::Scanner.in_site_models

    require 'postgres-copy'
    @models.each do |model|
      unless model.respond_to?(:copy_to)
        model.class_eval do
          acts_as_copy_target  # postgres-copy
        end
      end
    end
  end

  def dump
    id_map = Cms::Tasks::Site::Scanner.new(@site).scan_ids

    unless check_id_map_consistency(id_map)
      raise "invalid model and ids."
    end

    @models.each do |model|
      path = backup_file_path(model.table_name)
      data = model.unscoped.where(id: id_map[model.table_name]).copy_to_string
      Util::File.put(path, data: data, mkdir: true)

      yield model, id_map[model.table_name], path if block_given?
    end
  end

  def restore
    id_map = Cms::Tasks::Site::Scanner.new(@site).scan_ids

    unless check_id_map_consistency(id_map)
      raise "detect invalid consistency between models and ids."
    end
    unless check_backup_file_consistency
      raise "detect invalid consistency between models and backup files."
    end

    @models.each do |model|
      path = backup_file_path(model.table_name)
      ids = load_ids_from_dump_file(path)

      model.unscoped.where(id: id_map[model.table_name]).delete_all
      model.unscoped.where(id: ids).delete_all
      model.copy_from(path)

      yield model, ids, path if block_given?
    end
  end

  private

  def load_ids_from_dump_file(path)
    require 'csv'
    ids = []
    CSV.foreach(path, headers: true, header_converters: :symbol) do |row|
      ids << row[:id]
    end
    ids
  end

  def check_id_map_consistency(id_map)
    @models.each do |model|
      return false unless id_map.key?(model.table_name)
    end
    true
  end

  def check_backup_file_consistency
    @models.each do |model|
      path = backup_file_path(model.table_name)
      return false unless File.exist?(path)
    end
    true
  end

  def backup_file_path(table_name)
    "#{@dir}/sites/#{format('%04d', @site.id)}/db/#{table_name}.dump"
  end
end
