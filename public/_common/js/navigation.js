/**
 * Navigation
 */
function Navigation() {
}

Navigation.initialize = function(settings) {
  Navigation.settings = settings

  if (Navigation.settings['theme']) {
    jQuery.each(Navigation.settings['theme'], function(key, val) {
      $(key).on('click', function(){
        Navigation.theme(val);
        return false;
      });
    });
    Navigation.theme();
  }

  if (Navigation.settings['fontSize']) {
    jQuery.each(Navigation.settings['fontSize'], function(key, val) {
      $(key).on('click', function(){
        Navigation.fontSize(val);
        return false;
      });
    });
    Navigation.fontSize();
  }

  if (Navigation.settings['zoom']) {
    jQuery.each(Navigation.settings['zoom'], function(key, val) {
      $(key).on('click', function(){
        Navigation.zoom(val);
        return false;
      });
    });
    Navigation.zoom();
  }

  if (Navigation.settings['ruby']) {
    $(Navigation.settings['ruby']).on('click', function() {
      var flag = ($(this).attr('class') + '').match(/(^| )rubyOn( |$)/);
      Navigation.ruby( (flag ? 'off' : 'on'), 'kana' );
      return false;
    });
    if (Navigation.settings['rubyKana']) {
      $(Navigation.settings['rubyKana']).on('click', function() {
        Navigation.ruby(undefined, 'kana');
        return false;
      });
    }
    if (Navigation.settings['rubyRoman']) {
      $(Navigation.settings['rubyRoman']).on('click', function() {
        Navigation.ruby(undefined, 'roman');
        return false;
      });
    }
    Navigation.ruby();
  }

  if (Navigation.settings['talk']) {
    $(Navigation.settings['talk']).on('click', function(){
      var flag = ($(this).attr('class') + '').match(/(^| )talkOn( |$)/);
      Navigation.talk( (flag ? 'off' : 'on') );
      return false;
    });
  }
};

Navigation.theme = function(theme) {
  if (theme) {
    $.cookie('navigation_theme', theme, {path: '/'});
  } else {
    theme = $.cookie('navigation_theme');
  }
  if (theme) {
    $('link[title]').each(function() {
      this.disabled = true;
      if (theme == $(this).attr('title')) this.disabled = false;
    });
  }
};

Navigation.fontSize = function(size) {
  if (size) {
    $.cookie('navigation_font_size', size, {path: '/'});
  } else {
    size = $.cookie('navigation_font_size');
  }
  if (size) {
    $('body').css('font-size', size);
  }
};

Navigation.zoom = function(zoom) {
  if (zoom) {
    $.cookie('navigation_zoom', zoom, {path: '/'});
  } else {
    zoom = $.cookie('navigation_zoom');
  }
  if (zoom) {
    $('body').css('transform-origin', 'top left')
             .css('transform', 'scale(' + zoom + ')');
  }
};

Navigation.ruby = function(flag, type) {
  if (flag) {
    $.cookie('navigation_ruby', flag, {path: '/'});
  } else {
    flag = $.cookie('navigation_ruby');
  }
  if (type) {
    $.cookie('navigation_ruby_type', type, {path: '/'});
  } else {
    type = $.cookie('navigation_ruby_type');
  }

  var path;

  if (flag == 'on') {
    if (location.pathname.search(/\/$/i) != -1) {
      path = location.pathname + "index.html.r";
    } else if (location.pathname.search(/\.html\.mp3$/i) != -1) {
      path = location.pathname.replace(/\.html\.mp3$/, ".html.r");
    } else if (location.pathname.search(/\.html$/i) != -1) {
      path = location.pathname.replace(/\.html$/, ".html.r");
    }
  } else if (flag == 'off') {
    if (location.pathname.search(/\.html\.r$/i) != -1) {
      path = location.pathname.replace(/\.html\.r$/, ".html");
    }
  }

  if (path) {
    var host = location.protocol + "//" + location.hostname + (location.port ? ':' + location.port : '');
    location.href = host + path + location.search;
    return;
  }

  var elem = $(Navigation.settings['ruby']);
  var elemKana = $(Navigation.settings['rubyKana']);
  var elemRoman = $(Navigation.settings['rubyRoman']);

  elemKana.removeClass('current');
  elemRoman.removeClass('current');
  $('rt.kana, rt.roman').hide();

  if (flag == 'on') {
    if (type == 'roman') {
      $('rt.roman').show();
      elemRoman.addClass('current');
    } else {
      $('rt.kana').show();
      elemKana.addClass('current');
    }
    elem.removeClass('rubyOff');
    elem.addClass('rubyOn');
    elemKana.show();
    elemRoman.show();
    Navigation.notice();
  } else {
    elem.removeClass('rubyOn');
    elem.addClass('rubyOff');
    elemKana.hide();
    elemRoman.hide();
  }
};

Navigation.talk = function(flag) {
  var player = $(Navigation.settings['player']);
  var elem   = $(Navigation.settings['talk']);
  if (!player || !elem) return false;
  
  Navigation.notice();
  
  if (flag == 'off') {
    elem.removeClass('talkOn');
    elem.addClass('talkOff');
  } else {
    elem.removeClass('talkOff');
    elem.addClass('talkOn');
  }
   
  var uri = location.pathname;
  if (uri.match(/\/$/)) uri += 'index.html';
  uri = uri.replace(/\.html\.r$/, '.html');
  
  var now   = new Date();
  var param = '?85' + now.getDay() + now.getHours();
  
  if (player) {
    uri += '.mp3' + param;
    if (player.html() == '') {
      html = '<div id="navigationTalkCreatingFileNotice" style="display: none;">ただいま音声ファイルを作成しています。しばらくお待ちください。</div>';
      html += '<audio src=" ' + uri + '" id="naviTalkPlayer" controls autoplay />';
      player.html(html);

      $.ajax({type: "HEAD", url: uri, data: {file_check: '1'}, success: function(data, status, xhr) {
        var type = xhr.getResponseHeader('Content-Type');
        if (type.match(/^audio/)) {
          $('#navigationTalkCreatingFileNotice').hide();
        } else { 
          $('#navigationTalkCreatingFileNotice').show();
        }
      }});
    } else {
      player.html('');
      if ($.cookie('navigation_ruby') != 'on') Navigation.notice('off');
    }
  } else {
    location.href = uri;
  }
};

Navigation.notice = function(flag) {
  var wrap   = Navigation.settings['notice'] || 'container';
  var notice = $('#navigationNotice');
  
  if (flag == 'off') {
    notice.remove();
    return false;
  }
  if (notice.size()) return false;
  
  var elem = $(Navigation.settings['notice']);
  notice = document.createElement('div'); 
  notice.id = 'navigationNotice'; 
  notice.innerHTML = 'ふりがなと読み上げ音声は，' +
    '人名，地名，用語等が正確に発音されない場合があります。';
  // $(wrap + ' *:first').before(notice);
  $('#accessibilityTool').prepend(notice);
};
