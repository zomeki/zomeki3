// toggle open
jQuery.extend(jQuery.fn, {
  toggleOpen: function(target, openLabel, closeLabel, speed) {
    if (openLabel == undefined)  openLabel  = "開く▼";
    if (closeLabel == undefined) closeLabel = "閉じる▲";
    if (speed == undefined) speed = 200;

    if (jQuery(target).css('display') == 'none') {
      jQuery(this).html(closeLabel);
    } else {
      jQuery(this).html(openLabel);
    }

    if (speed == 0) {
      jQuery(target).toggle(speed);
    } else {
      jQuery(target).slideToggle(speed);
    }
  }
});

// add fields
jQuery.extend(jQuery.fn, {
  addFields: function(options) {
    var button = jQuery(this);
    var setting = jQuery.extend({
      container: '.container',
      fields: '.fields',
      startIndex: 0,
      indexName: '_attributes',
      replaceTags: {
        input: ['id', 'name'],
        textarea: ['id', 'name'],
        select: ['id', 'name'],
        label: ['for']
      },
      extraReplaceTags: undefined,
      beforeAdd: undefined,
      afterAdd: undefined
    }, options);

    if (Array.isArray(setting.indexName)) {
      setting.indexNames = setting.indexName;
    } else {
      setting.indexNames = [setting.indexName];
    }

    if (setting.extraReplaceTags) {
      jQuery.extend(setting.replaceTags, setting.extraReplaceTags);
    };

    button.on('click', function(e) {
      e.preventDefault();

      var clone = jQuery(setting.container).find(setting.fields + ':last').clone(true);
      clearInputValue(clone);
      replaceIndex(clone);

      if (setting.beforeAdd) {
        setting.beforeAdd(clone);
      }

      jQuery(setting.container).append(clone);

      if (setting.afterAdd) {
        setting.afterAdd(clone);
      }
    });

    var clearInputValue = function(clone) {
      clone.find('textarea').text('');
      clone.find('input[type="text"]').val('').removeAttr('value');
      clone.find('input[type="checkbox"], input[type="radio"]').prop('checked', false);
      clone.find('option').prop('selected', false);

      // check first radio button
      var names = findRadioButtonNames(clone);
      names.forEach(function(name) {
        clone.find('input[type="radio"][name="' + name +'"]').first().prop('checked', true);
      });

      // remove hidden field for nested form
      var regexps = makeRegexpsForNestedFormID();
      clone.find('input[type="hidden"]').each(function() {
        var elem = $(this);
        var id = elem.attr('id');
        regexps.forEach(function(regexp) {
          if (id =~ regexp) {
            elem.remove();
            return;
          }
        });
      });
    };

    var findRadioButtonNames = function(clone) {
      var names = [];
      clone.find('input[type="radio"]').each(function() {
        var name = $(this).attr('name');
        if (names.indexOf(name) == -1) { names.push(name); }
      });
      return names;
    };

    var makeRegexpsForNestedFormID = function() {
      return setting.indexNames.map(function(name) {
        new RegExp(name + '_\\d+_id');
      });
    };

    var replaceIndex = function(clone) {
      var nextID = jQuery(setting.container).find(setting.fields).length + setting.startIndex;
      var regs = makeRegexpsForReplace();

      for (tag in setting.replaceTags) {
        var attrs = setting.replaceTags[tag];
        clone.find(tag).each(function() {
          var elem = jQuery(this);
          attrs.forEach(function(attr) {
            var value = elem.attr(attr);
            if (value) {
              regs.forEach(function(reg) {
                value = value.replace(reg, '$1' + nextID);
              });
              elem.attr(attr, value);
            }
          });
        });
      }
    };

    var makeRegexpsForReplace = function() {
      var regexps = [];
      setting.indexNames.forEach(function(name) {
        regexps.push(new RegExp('(' + name + '_)\\d+'));
        regexps.push(new RegExp('(' + name + '\\[)\\d+'));
        regexps.push(new RegExp('(' + name + '\\]\\[)\\d+'));
      });
      return regexps;
    };
  }
});

// simple multi select
jQuery.extend(jQuery.fn, {
  simpleMultiSelect: function(options) {
   var form = $(this);
    var setting = jQuery.extend({
      source: '.source',
      destination: '.destination',
      add: '.add',
      remove: '.remove',
      beforeAdd: undefined,
      afterAdd: undefined,
      afterRemove: undefined,
      afterRemove: undefined,
    }, options);

    form.on('submit', function() {
      form.find(setting.source).find('option').prop('selected', false);
      form.find(setting.destination).find('option').prop('selected', true);
    });
    form.find(setting.add).on('click', function() {
      addSelectedOptions();
    });
    form.find(setting.source).on('dblclick', function() {
      addSelectedOptions();
    });
    form.find(setting.remove).on('click', function() {
      removeSelectedOptions();
    });
    form.find(setting.destination).on('dblclick', function() {
      removeSelectedOptions();
    });

    var addSelectedOptions = function() {
      var from = form.find(setting.source);
      var to = form.find(setting.destination);
      from.find('option:selected').each(function() {
        var option = $(this);
        if (to.find('option[value="' + option.val() + '"]').length == 0) {
          option.prop('selected', false);

          if (setting.beforeAdd && setting.beforeAdd(option) == false) { return; }
          to.append(option);
          if (setting.afterAdd && setting.afterAdd(option) == false) { return; }
        }
      });
    };

    var removeSelectedOptions = function() {
      var from = form.find(setting.destination);
      var to = form.find(setting.source);
      from.find('option:selected').each(function() {
        var option = $(this);
        if (to.find('option[value="' + option.val() + '"]').length == 0) {
          option.prop('selected', false);

          if (setting.beforeRemove && setting.beforeRemove(option) == false) { return; }
          to.append(option);
          if (setting.afterRemove && setting.afterRemove(option) == false) { return; }
        }
      });
    };
  }
});

jQuery(function() {
  jQuery('form.new_item, form.edit_item').on('keypress', function(e) {
    if (e.target.type !== 'textarea' && e.which === 13) return false;
  });

  function beforeunload() {
    jQuery(window).on('beforeunload', function() {
      return 'このページを離れるとフォームに入力したデータが失われます。本当に移動してよろしいですか？';
    });
  }
  jQuery('form.new_item, form.edit_item').on('change', beforeunload);
  if (typeof CKEDITOR != 'undefined') {
    for (var i in CKEDITOR.instances) {
      CKEDITOR.instances[i].on('change', beforeunload);
    }
  }
  jQuery('form.new_item input[type=submit], form.edit_item input[type=submit]').on('click', function(e) {
    jQuery(window).off('beforeunload');
  });
});
