$(document).ready(function(){
// Block Skip
  $("#nocssread a").focus(function(){
    $(this).addClass("show");
  });
  $("#nocssread a").blur(function(){
    $(this).removeClass("show");
  });

// External Icon
  $("a[href^='http']").not("[href^='http://"+location.host+"'],[href^='https://"+location.host+"'],[href^='http://http://city.sitebridge.jp/']").append("<img src='/_themes/base/images/ic-blank.gif' alt='新しいウィンドウで外部サイトを開きます' class='external' />").attr("target","_blank");
  $("a img + img.external").remove();

// Roll Over
  $("a img").hover(function(){
    $(this).attr("src", $(this).attr("src").replace("_off", "_on"));
  },function(){
    if (!$(this).parent("a").hasClass("cur")){
      $(this).attr("src", $(this).attr("src").replace("_on", "_off"));
    }
  });

// smart toggle menu
  spMenuFunc(".slideMenu > div");

// bxslider
  if($("#keyvisual ul")[0]){
    $("#keyvisual ul").bxSlider({
      auto: true,
      speed: 1500,
      pause: 10000,
      autoControls: true
    });
  }

// naviRollover
  naviRollOverFunc("#globalNavi");
  naviRollOverFunc("#sideMenu");
  naviRollOverFunc("#sideNavi");
  naviRollOverFunc("#eventType");
  $("ul li a[href*='#']").removeClass("cur");  // hash

// simple tabs
  if($("#simple_tabs")[0]){
    enable_simple_tabs();
  }

// event tracking
  $("a.iconFile").click(function(e){
    var title = $(this).text().replace(/\[.+\]/g,'');
    ga('send', 'event', '添付ファイル', 'クリック', title);
  });

});

// smart toggle menu
// spMenuFunc("#sideMenu")
function spMenuFunc(element){
  var agent = navigator.userAgent;
  if((agent.search(/iPhone/) != -1) || (agent.search(/iPad/) != -1) || (agent.search(/Android/) != -1)){
    if($(element)[0]){
      if($(element).find(".pieceHeader")[0]){
        $(element).find(".pieceHeader").children("h2").wrapInner('<a href="javascript:void(0);"></a>');
        $(element).find(".pieceBody").hide();
        $(element).find(".pieceHeader").on('click','a',function(){
          $(this).closest("div").toggleClass("open");
          $(this).closest("div").next("div").slideToggle();
        });
      } else if($(element).find(".smartTitle")[0]){
        $(element).find(".pieceBody").hide();
        $(element).find(".smartTitle").on('click','a',function(){
          $(this).closest("div").toggleClass("open");
          $(this).closest("div").next("div").slideToggle();
        });
      }
    }
  }
}

// naviRollOver
// naviRollOverFunc("#globalNavi")
function naviRollOverFunc(element,setTag){
  if($(element)[0]){
    var curTag = setTag || "ul li a";
    $(element).naviRollOver({
      type: 'html',
      firstStrictCheck: false,
      tag: curTag
    });
  }
}

$(window).on('load',function(){
  $("#gsearchbox").show();  // search
});

function enable_simple_tabs() {
  var simple_tabs = $('#simple_tabs > li');
  var simple_tab_panels = $('#simple_tab_panels > div');

  var index;
  simple_tabs.on('click', function () {
    if (index != simple_tabs.index(this)) {
      index = simple_tabs.index(this);
      simple_tab_panels.hide().eq(index).show();
      simple_tabs.removeClass('current').eq(index).addClass('current');
    }
  });

  $(simple_tabs[0]).trigger('click');
}