jQuery.extend(jQuery.fn, {
  // toggle open
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

jQuery(function() {
  jQuery('form.new_item, form.edit_item').on('keypress', function (e) {
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
