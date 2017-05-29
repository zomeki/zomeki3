module FormHelper
  ## CKEditor
  def init_ckeditor(options = {})
    settings = []

    # リードオンリーではツールバーを表示しない・リンクを動作させる
    unless (options[:toolbarStartupExpanded] = !options[:readOnly])
      settings.push(<<-EOS)
        CKEDITOR.on('instanceReady', function (e) {
          $('#'+e.editor.id+'_top').hide();
          var links = $('#'+e.editor.id+'_contents > iframe:first').contents().find('a');
          for (var i = 0; i < links.length; i++) {
            $(links[i]).click(function (ee) { location.href = ee.target.href; });
          }
        });
      EOS
    end

    settings.concat(options.map {|k, v|
      %Q(CKEDITOR.config.#{k} = #{v.kind_of?(String) ? "'#{v}'" : v};)
    })

    [ '<script type="text/javascript" src="/_common/js/ckeditor/ckeditor.js"></script>',
      javascript_tag(settings.join) ].join.html_safe
  end

  def submission_label(name)
    {
      :add       => '追加する',
      :create    => '作成する',
      :register  => '登録する',
      :edit      => '編集する',
      :update    => '更新する',
      :change    => '変更する',
      :delete    => '削除する',
      :make      => '作成する'
    }[name]
  end

  def submit(*args)
    make_tag = Proc.new do |_name, _label|
      _label ||= submission_label(_name) || _name.to_s.humanize
      submit_tag _label, :name => "commit_#{_name}"
    end
    
    h = '<div class="submitters">'
    if args[0].class == String || args[0].class == Symbol
      h += make_tag.call(args[0], args[1])
    elsif args[0].class == Hash
      args[0].each {|k, v| h += make_tag.call(k, v) }
    elsif args[0].class == Array
      args[0].each {|v, k| h += make_tag.call(k, v) }
    end
    h += '</div>'
    h.html_safe
  end
  
  def value_for_datepicker(object_name, attribute)
    if object = instance_variable_get("@#{object_name}")
      object.send(attribute).try(:strftime, '%Y-%m-%d')
    end
  end

  def enable_datepicker_script
    s = <<-EOS
$('.datepicker').datepicker();
    EOS
    s.html_safe
  end

  def value_for_datetimepicker(object_name, attribute)
    if object = instance_variable_get("@#{object_name}")
      object.send(attribute).try(:strftime, '%Y-%m-%d %H:%M')
    end
  end

  def enable_datetimepicker_script
    s = <<-EOS
$('.datetimepicker').datetimepicker({
  hourGrid: 4,
  minuteGrid: 10,
  secondGrid: 10
});
    EOS
    s.html_safe
  end

  def value_for_timepicker(object_name, attribute)
    if object = instance_variable_get("@#{object_name}")
      object.send(attribute).try(:strftime, '%H:%M')
    end
  end

  def enable_timepicker_script
    s = <<-EOS
$('.timepicker').timepicker({
  hourGrid: 4,
  minuteGrid: 10,
  secondGrid: 10
});
    EOS
    s.html_safe
  end


  def disable_enter_script
    s = <<-EOS
$('form').on('keypress', function (e) { if (e.target.type !== 'textarea' && e.which === 13) return false; });
    EOS
    s.html_safe
  end
end
