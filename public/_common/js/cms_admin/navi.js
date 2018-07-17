(function($) {
  $(function() {
    $('#currentNaviSite').on('click', function() {
      $('#naviConcepts').hide();

      var $view = $('#naviSites');
      if ($view.attr('id')) {
        $view.toggle();
      } else {
        if (this.loading) return false;
        this.loading = true;

        var uri = $(this).attr('href');
        $.ajax({
          url: uri,
          success: function(data, dataType) {
            $('#content').prepend(data);
          }
        });
      }
      return false;
    });

    $('#currentNaviConcept').on('click', function() {
      $('#naviSites').hide();
      $('#naviConcepts').toggle();
      $.cookie("naviConceptsVisible", $('#naviConcepts').is(':visible'), { path: '/' });
    });
  });
})(jQuery);
