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

// ad-banner
  altToTitleFunc("#bnAdvertisement ul li a");
  altToTitleFunc("#bnAdvertisementSide ul li a");

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

// heightLine
  adjacentHeightLineFunc(".contentGpCategoryCategoryTypes .bunya > ul > li", 3);  // categoryTypes
// simple tabs
  if($("#simple_tabs")[0]){
    enable_simple_tabs();
  }
/*
  // category link
  $("#category section a, .contentGpCategoryCategoryType a, .contentGpCategory section a, #categoryList .pieceBody a, #lifeeventList .pieceBody a").each(function(){
    var url = null;
    var url = $(this).attr("href").replace(/\/$/g,'/rank.html');
    $(this).attr("href",url);
  });
  // breadCrumbs link more
  $("#breadCrumbs a[href^='/faq/bunya/']").each(function(){
    if($(this).attr("href") != "/faq/bunya/"){
      var url = null;
      var url = $(this).attr("href").replace(/\/$/g,'/rank.html');
      $(this).attr("href",url);
    }
  });
  $("#breadCrumbs a[href^='/faq/lifeevent/']").each(function(){
    if($(this).attr("href") != "/faq/lifeevent/"){
      var url = null;
      var url = $(this).attr("href").replace(/\/$/g,'/rank.html');
      $(this).attr("href",url);
    }
  });
*/

  // ...
  if($(".contentGpCategoryCategory .docs li .body")[0]){
    $(".contentGpCategoryCategory .docs li .body").each(function(){
      var str = "";
      var str = $(this).text().replace(/...$/g,'・・・');
      $(this).text(str);
    });
  }
  // category class
  $("#breadCrumbs .pieceBody > div").each(function(){
    var category = null;
    var category = $(this).children("a:last-child").attr("href").split("/");
    $("#container").addClass(category[category.length-2]);
  });

// event tracking
  $("a.iconFile").click(function(e){
    var title = $(this).text().replace(/\[.+\]/g,'');
    ga('send', 'event', '添付ファイル', 'クリック', title);
  });

});

// adjacent heightLine
// adjacentHeightLineFunc(".contentGpCategoryCategoryTypes section > ul > li", 3)
function adjacentHeightLineFunc(element,column){
  if($(element)[0]){
    var sets = [], temp = [];
    $(element).each(function(i){    // make up a party
      temp.push(this);
      if(i % column == (column - 1)){
        sets.push(temp);
        temp = [];
      }
    });
    if (temp.length) sets.push(temp);
    $.each(sets, function(){    // set heightLine for party
      $(this).heightLine({minWidth:600, fontSizeCheck:true});
    });
    $("#accessibilityTool .fontSize a").click(function(){    // heightLine initialize
      $(element).heightLine("refresh");
    });
  }
}

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

// img set alt title
// altToTitleFunc("#bnAdvertisement ul li a")
function altToTitleFunc(element){
  if($(element)[0]){
    $(element).each(function(){
      $(this).children("img").attr("title", ($(this).children("img").attr("alt")));
    });
  }
}

// preload
// preloadFunc("01.png", "02.png", "03.png", … )
function preloadFunc(){
  for(var i = 0; i< arguments.length; i++){
    $("<img>").attr("src", arguments[i]);
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