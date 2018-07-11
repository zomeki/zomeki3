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
jQuery.extend(jQuery.fn, {
  simpleTree: function(options) {
    var tree = jQuery(this);
    var setting = jQuery.extend({
      openAll: '.openAll',
      closeAll: '.closeAll',
      icon: 'a.icon'
    }, options);

    tree.find(setting.openAll).on('click', function() {
      tree.find('a.closed ~ ul').show();
      tree.find('a.closed').html('-').removeClass('closed').addClass('opened');
    });
    tree.find(setting.closeAll).on('click', function() {
      tree.find('a.opened ~ ul').hide();
      tree.find('a.opened').html('+').removeClass('opened').addClass('closed');
    });
    tree.find(setting.icon).on('click', function() {
      var ul = jQuery(this).siblings('ul');
      ul.toggle();
      if (ul.is(':visible')) {
        jQuery(this).html('-').addClass('opened').removeClass('closed');
      } else {
        jQuery(this).html('+').addClass('closed').removeClass('opened');
      }
      return false;
    });
  }
});
