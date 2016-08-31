module Sys::Model::Base::Transfer
  extend ActiveSupport::Concern

  included do
    belongs_to :site, :class_name => 'Cms::Site'
    belongs_to :user, :class_name => 'Sys::User'

    scope :search_with_params, ->(params = {}) {
      rel = all
      params.each do |n, v|
        next if v.to_s == ''
        case n
        when 's_version'
          rel.where!(version: v)
        when 's_operation'
          rel.where!(operation: v)
        when 's_file_type'
          rel.where!(file_type: v)
        when 's_path'
          rel.where!(arel_table[:path].matches("%#{escape_like(v)}%"))
        when 's_item_name'
          rel.where!(arel_table[:item_name].matches("%#{escape_like(v)}%"))
        when 's_operator_name'
          rel.where!(arel_table[:operator_name].matches("%#{escape_like(v)}%"))
        end
      end
      rel
    }
  end

  def operations
    [['作成','create'],['更新','update'],['削除','delete']]
  end

  def operation_label
    operations.each {|a| return a[0] if a[1] == operation }
    return nil
  end

  def file_types
    [['ディレクトリ','directory'],['ファイル','file']]
  end

  def file_type_label
    file_types.each {|a| return a[0] if a[1] == file_type }
    return nil
  end

  def file?
    file_type.to_s == 'file'
  end

  def operation_is?(op)
    operation.to_s == op.to_s
  end

  def item_info(attr)
    return @item_info[attr] || '-' if @item_info

    # cms_data_files
    if path =~ /^_files\/.+?$/
      #data = Cms::DataFile.find_by_public_path("#{parent_dir}#{_path}")
      "#{parent_dir}#{_path}" =~ /sites\/.*\/(.*?)\/public\/_files\/.*\/(.*?)\/(.*?)$/i
      _site_id = $1.to_i rescue 0;
      _id      = $2[0 .. -2].to_i rescue 0;
      if log = Sys::OperationLog.where(:site_id => _site_id, :item_id => _id, :item_model => 'Cms::DataFile').order(id: :desc).first
        @item_info = {}
        @item_info[:item_id]       = log.item_id
        @item_info[:item_unid]     = log.item_unid
        @item_info[:item_model]    = log.item_model
        @item_info[:item_name]     = "データファイル：#{log.item_name}";
        @item_info[:operated_at]   = log.created_at
        @item_info[:operator_id]   = log.user_id
        @item_info[:operator_name] = log.user_name
        return @item_info[attr] || '-'
      end
    end

    _path       = path
    _attachment = nil
    if path =~ /^.+?\/file_contents\/(.+?)$/
      # sys_files
      _attachment = $1
      _path = path.gsub(/\/file_contents\/.+?$/, '/index.html')
    end

    # sys_publishers
    pub = Sys::Publisher.where(:path => "#{parent_dir}#{_path}").order(id: :desc).first
    pub ||= Sys::Closer.where(:path => "#{parent_dir}#{_path}").order(id: :desc).first
    if pub
      if log = Sys::OperationLog.where(:item_unid => pub.unid).order(id: :desc).first
        @item_info = {}
        @item_info[:item_id]       = log.item_id
        @item_info[:item_unid]     = log.item_unid
        @item_info[:item_model]    = log.item_model
        @item_info[:item_name]     = _attachment ? "#{log.item_name}（添付ファイル：#{_attachment}）" : log.item_name;
        if pub.updated_at - 2*60 > log.updated_at
          # by process
          @item_info[:operated_at]   = pub.created_at
        else
          @item_info[:operated_at]   = log.created_at
          @item_info[:operator_id]   = log.user_id
          @item_info[:operator_name] = log.user_name
        end

        return @item_info[attr] || '-'
      end
    end
    '-'
  end

  module_function :operations
  module_function :file_types
end
