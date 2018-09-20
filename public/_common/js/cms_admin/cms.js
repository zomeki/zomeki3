(function (window, undefined) {
  if (window.cms !== undefined) {
    return;
  }

  var cms = {
    Core: {},
    Page: {}
  };

  window.cms = cms;
})(window);


// simple tree
(function($) {
  $.extend($.fn, {
    simpleTree: function(options) {
      var $tree = $(this);
      var setting = $.extend({
        openAll: '.openAll',
        closeAll: '.closeAll',
        icon: 'a.icon'
      }, options);

      $tree.find(setting.openAll).on('click', function() {
        $tree.find('a.closed ~ ul').show();
        $tree.find('a.closed').html('-').removeClass('closed').addClass('opened');
      });
      $tree.find(setting.closeAll).on('click', function() {
        $tree.find('a.opened ~ ul').hide();
        $tree.find('a.opened').html('+').removeClass('opened').addClass('closed');
      });
      $tree.find(setting.icon).on('click', function() {
        var $ul = $(this).siblings('ul');
        $ul.toggle();
        if ($ul.is(':visible')) {
          $(this).html('-').addClass('opened').removeClass('closed');
        } else {
          $(this).html('+').addClass('closed').removeClass('opened');
        }
        return false;
      });
    }
  });
})(jQuery);

// table tree
(function($) {
  $.extend($.fn, {
    tableTree: function(options) {
      var $tree = $(this);
      var setting = $.extend({
        openAll: '.openAll',
        closeAll: '.closeAll',
        icon: 'a.icon'
      }, options);

      $tree.find(setting.openAll).on('click', function() {
        $tree.find('tr').show();
        $tree.find('a.closed').html('-').removeClass('closed').addClass('opened');
      });
      $tree.find(setting.closeAll).on('click', function() {
        $tree.find('tr').hide();
        $tree.find('a.opened').html('+').removeClass('opened').addClass('closed');
      });
      $tree.find(setting.icon).on('click', function() {
        var id = $(this).attr('data-tree-id');
        var children = $tree.find('tr[data-tree-id^="' + id + '"]');
        children.toggle();
        if (children.is(':visible')) {
          $(this).html('-').addClass('opened').removeClass('closed');
        } else {
          $(this).html('+').addClass('closed').removeClass('opened');
        }
        return false;
      });
    }
  });
})(jQuery);
