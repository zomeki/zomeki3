$(function() {
  $('#currentNaviSite').click(function() {
    $('#naviConcepts').hide();

    var view = $('#naviSites');
    if (view.attr('id')) {
      view.toggle();
    } else {
      if (this.loading) return false;
      this.loading = true;
      
      var uri = $(this).attr('href');
      jQuery.ajax({
        url: uri,
        success: function(data, dataType) {
          $('#content').prepend(data);
          addHandler_onClickConceptIcon();
        }
      });
    }
    return false;
  });

  $('#currentNaviConcept').click(function() {
    $('#naviSites').hide();
    $('#naviConcepts').toggle();
    $.cookie("naviConceptsVisible", $('#naviConcepts').is(':visible'), { path: '/' });
  });
});
