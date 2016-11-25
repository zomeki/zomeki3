module Cms::FormHelper
  def node_navi
    render 'cms/admin/_partial/nodes/navi'
  end

  def concept_and_layout_form(form, options = {})
    #return form.hidden_field(:concept_id) unless Core.user.has_auth?(:manager)
    item = instance_variable_get("@#{form.object_name}")
    render 'cms/admin/_partial/concepts/form', {f: form, item: item, layout: true}.merge(options)
  end

  def concept_form(form, options = {})
    #return form.hidden_field(:concept_id) unless Core.user.has_auth?(:manager)
    item = instance_variable_get("@#{form.object_name}")
    render 'cms/admin/_partial/concepts/form', {f: form, item: item}.merge(options)
  end

  def concept_view(item, options = {})
    render 'cms/admin/_partial/concepts/view', {item: item}.merge(options)
  end

  def layout_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    render 'cms/admin/_partial/layouts/form', {f: form, item: item}.merge(options)
  end

  def layout_view(item, options = {})
    render 'cms/admin/_partial/layouts/view', {item: item}.merge(options)
  end

  def content_base_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    render 'cms/admin/_partial/contents/form', {f: form, item: item}.merge(options)
  end

  def content_base_view(item, options = {})
    render 'cms/admin/_partial/contents/view', {item: item}.merge(options)
  end

  def node_base_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    render 'cms/admin/_partial/nodes/form', {f: form, item: item}.merge(options)
  end

  def node_base_view(item, options = {})
    render 'cms/admin/_partial/nodes/view', {item: item}.merge(options)
  end

  def piece_base_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    render 'cms/admin/_partial/pieces/form', {f: form, item: item}.merge(options)
  end

  def piece_base_view(item, options = {})
    render 'cms/admin/_partial/pieces/view', {item: item}.merge(options)
  end

  def piece_base_menu(item, options = {})
    render 'cms/admin/_partial/pieces/menu', {item: item}.merge(options)
  end

  def google_map_form(form)
    item = form.object || instance_variable_get("@#{form.object_name}")
    render 'cms/admin/_partial/maps/form', f: form, item: item
  end

  def google_map_view(item)
    render 'cms/admin/_partial/maps/view', item: item
  end

  def value_form(f, css = nil)
    object = f.object || instance_variable_get("@#{f.object_name}")
    case object.form_type
    when :select
      options = if (co = object.config_options).kind_of?(Proc)
                  co.call(object.content)
                else
                  co
                end
      f.select(:value, options, include_blank: true)
    when :text
      f.text_area(:value, style: css ? css : 'width: 600px; height: 120px;')
    when :check_boxes
      f.collection_check_boxes(:value, object.config_options, :last, :first)
    when :radio_buttons
      f.collection_radio_buttons(:value, object.config_options, :last, :first)
    when :multiple_select
      select_tag 'item[value]', options_from_collection_for_select(object.config_options.where(id: object.value), :id, :name),
                                multiple: true, style: 'height: 150px; width: 250px;'
    when :text_area
      f.text_area(:value, size: '100x10', style: css)
    when :table_field
      render 'shared/admin/content/settings/table_form', f: f
    else
      f.text_field(:value, style: css ? css : 'width: 400px;')
    end
  end

  def toggle_form_function
    f = <<-EOS
function toggle_form(link, target, open_label, close_label, quick) {
  if (open_label === undefined) open_label = '開く▼';
  if (close_label === undefined) close_label = '閉じる▲';
  var l = jQuery(link);
  var t = jQuery(target);
  if (t.is(':hidden')) {
    l.html(close_label);
  } else {
    l.html(open_label);
  }
  if (quick) {
    t.toggle();
  } else {
    t.slideToggle();
  }
}

$('a[data-toggle-form]').on('click', function (e) {
  toggle_form(this, $(this).data('toggle-form'));
});
    EOS
    f.html_safe
  end

  def piece_replace_menu(item)
    if rep = item.replaced_page
      %Q(<div class="noticeBox">更新用のピースが作成されています : #{link_to h(rep.title), rep.admin_uri}</div>).html_safe
    elsif org = item.replace_page
      %Q(<div class="noticeBox">公開時に更新されるピース : #{link_to h(org.title), org.admin_uri}</div>).html_safe
    end
  end

end
