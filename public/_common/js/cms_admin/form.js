// toggle open
(function($) {
  $.extend($.fn, {
    toggleOpen: function(target, openLabel, closeLabel, speed) {
      if (openLabel == undefined) { openLabel  = "開く▼"; }
      if (closeLabel == undefined) { closeLabel = "閉じる▲"; }
      if (speed == undefined) { speed = 200; }

      if ($(target).css('display') == 'none') {
        $(this).html(closeLabel);
      } else {
        $(this).html(openLabel);
      }

      if (speed == 0) {
        $(target).toggle(speed);
      } else {
        $(target).slideToggle(speed);
      }
    }
  });
})(jQuery);

// add fields
(function($) {
  $.extend($.fn, {
    addFields: function(options) {
      var $button = $(this);
      var setting = $.extend({
        container: '.container',
        fields: '.fields',
        cloneEvents: true,
        startIndex: 0,
        indexName: '_attributes',
        replaceTags: {
          input: ['id', 'name'],
          textarea: ['id', 'name'],
          select: ['id', 'name'],
          label: ['for']
        },
        extraReplaceTags: null,
        beforeAdd: null,
        afterAdd: null
      }, options);

      if (Array.isArray(setting.indexName)) {
        setting.indexNames = setting.indexName;
      } else {
        setting.indexNames = [setting.indexName];
      }

      if (setting.extraReplaceTags) {
        $.extend(setting.replaceTags, setting.extraReplaceTags);
      };

      $button.on('click', function(e) {
        e.preventDefault();

        var $clone = $(setting.container).find(setting.fields + ':last').clone(setting.cloneEvents);
        clearInputValue($clone);
        replaceIndex($clone);

        if (setting.beforeAdd) {
          setting.beforeAdd($clone);
        }

        $(setting.container).append($clone);

        if (setting.afterAdd) {
          setting.afterAdd($clone);
        }
      });

      function clearInputValue($clone) {
        $clone.find('textarea').text('');
        $clone.find('input[type="text"]').val('').removeAttr('value');
        $clone.find('input[type="checkbox"], input[type="radio"]').prop('checked', false);
        $clone.find('option').prop('selected', false);

        // check first radio button
        var names = findRadioButtonNames($clone);
        names.forEach(function(name) {
          $clone.find('input[type="radio"][name="' + name +'"]').first().prop('checked', true);
        });

        // remove hidden field for nested form
        var regexps = makeRegexpsForNestedFormID();
        $clone.find('input[type="hidden"]').each(function() {
          var $elem = $(this);
          var id = $elem.attr('id');
          if (!id) { return; }
          regexps.forEach(function(regexp) {
            if (id.match(regexp)) {
              $elem.remove();
              return;
            }
          });
        });
      }

      function findRadioButtonNames($clone) {
        var names = [];
        $clone.find('input[type="radio"]').each(function() {
          var name = $(this).attr('name');
          if (names.indexOf(name) == -1) { names.push(name); }
        });
        return names;
      }

      function makeRegexpsForNestedFormID() {
        var regexps = [];
        setting.indexNames.forEach(function(name) {
          regexps.push(new RegExp(name + '_\\d+_id'));
        });
        return regexps;
      }

      function replaceIndex($clone) {
        var nextID = $(setting.container).find(setting.fields).length + setting.startIndex;
        var regs = makeRegexpsForReplace();

        for (tag in setting.replaceTags) {
          var attrs = setting.replaceTags[tag];
          $clone.find(tag).each(function() {
            var $elem = $(this);
            attrs.forEach(function(attr) {
              var value = $elem.attr(attr);
              if (value) {
                regs.forEach(function(reg) {
                  value = value.replace(reg, '$1' + nextID);
                });
                $elem.attr(attr, value);
              }
            });
          });
        }
      }

      function makeRegexpsForReplace() {
        var regexps = [];
        setting.indexNames.forEach(function(name) {
          regexps.push(new RegExp('(' + name + '_)\\d+'));
          regexps.push(new RegExp('(' + name + '\\[)\\d+'));
          regexps.push(new RegExp('(' + name + '\\]\\[)\\d+'));
        });
        return regexps;
      }
    }
  });
})(jQuery);

// simple multi select
(function($) {
  $.extend($.fn, {
    simpleMultiSelect: function(options) {
     var $container = $(this);
      var setting = $.extend({
        source: '.source',
        destination: '.destination',
        add: '.add',
        remove: '.remove',
        beforeAdd: undefined,
        afterAdd: undefined,
        afterRemove: undefined,
        afterRemove: undefined,
      }, options);

      $container.closest('form').on('submit', function() {
        $container.find(setting.source).find('option').prop('selected', false);
        $container.find(setting.destination).find('option').prop('selected', true);
      });
      $container.find(setting.add).on('click', function() {
        addSelectedOptions();
      });
      $container.find(setting.source).on('dblclick', function() {
        addSelectedOptions();
      });
      $container.find(setting.remove).on('click', function() {
        removeSelectedOptions();
      });
      $container.find(setting.destination).on('dblclick', function() {
        removeSelectedOptions();
      });

      function addSelectedOptions() {
        var $from = $container.find(setting.source);
        var $to = $container.find(setting.destination);
        $from.find('option:selected').each(function() {
          var option = $(this);
          if ($to.find('option[value="' + option.val() + '"]').length == 0) {
            option.prop('selected', false);
  
            if (setting.beforeAdd && setting.beforeAdd(option) == false) { return; }
            $to.append(option);
            if (setting.afterAdd && setting.afterAdd(option) == false) { return; }
          }
        });
      }

      function removeSelectedOptions() {
        var $from = $container.find(setting.destination);
        var $to = $container.find(setting.source);
        $from.find('option:selected').each(function() {
          var option = $(this);
          if ($to.find('option[value="' + option.val() + '"]').length == 0) {
            option.prop('selected', false);

            if (setting.beforeRemove && setting.beforeRemove(option) == false) { return; }
            $to.append(option);
            if (setting.afterRemove && setting.afterRemove(option) == false) { return; }
          }
        });
      }
    }
  });
})(jQuery);

(function($) {
  $(function() {
    // ignore enter key
    $('form.new_item, form.edit_item').on('keypress', function(e) {
      if (e.target.type !== 'textarea' && e.which === 13) { return false; }
    });

    // show message before move to another page
    function beforeunload() {
      $(window).on('beforeunload', function() {
        return 'このページを離れるとフォームに入力したデータが失われます。本当に移動してよろしいですか？';
      });
    }
    $('form.new_item, form.edit_item').on('change', beforeunload);
    if (typeof CKEDITOR != 'undefined') {
      for (var i in CKEDITOR.instances) {
        CKEDITOR.instances[i].on('change', beforeunload);
      }
    }
    $('form.new_item input[type=submit], form.edit_item input[type=submit]').on('click', function(e) {
      $(window).off('beforeunload');
    });
  });
})(jQuery);
