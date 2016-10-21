class GpCategory::Admin::Content::SettingsController < Cms::Admin::Content::SettingsController
  def model
    GpCategory::Content::Setting
  end

  def copy_groups
    category_type = @content.category_types.find_by(name: @content.group_category_type_name) ||
                    @content.category_types.create(name: @content.group_category_type_name, title: '組織')
    category_type.copy_from_groups(Sys::Group.where(parent_id: 1, level_no: 2))
    redirect_to gp_category_content_settings_path, notice: 'コピーが完了しました。'
  end
end
