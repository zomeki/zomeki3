module Sys::FormHelper
  def creator_form(form)
    item = form.object || instance_variable_get("@#{form.object_name}")
    render 'sys/admin/_partial/creators/form', f: form, item: item
  end

  def creator_view(item)
    render 'sys/admin/_partial/creators/view', item: item
  end
  
  def recognizer_form(form)
    item = form.object || instance_variable_get("@#{form.object_name}")
    render 'sys/admin/_partial/recognizers/form', f: form, item: item
  end
  
  def recognizer_view(item)
    render 'sys/admin/_partial/recognizers/view', item: item
  end
  
  def task_form(form)
    item = instance_variable_get("@#{form.object_name}")
    render 'sys/admin/_partial/tasks/form', f: form, item: item
  end
  
  def task_view(item)
    render 'sys/admin/_partial/tasks/view', item: item
  end
  
  def editable_group_form(form)
    item = instance_variable_get("@#{form.object_name}")
    render 'sys/admin/_partial/editable_groups/form', f: form, item: item
  end
  
  def editable_group_view(item)
    render 'sys/admin/_partial/editable_groups/view', item: item
  end
end
