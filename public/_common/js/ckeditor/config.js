/**
 * @license Copyright (c) 2003-2018, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see https://ckeditor.com/legal/ckeditor-oss-license
 */

CKEDITOR.editorConfig = function( config ) {
  // Define changes to default configuration here. For example:
  // config.language = 'fr';
  // config.uiColor = '#AADC6E';

  config.skin = 'moono';
  config.height = 300;

  // ツールバーの設定
  // http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.config.html#.toolbar_Full
  if (cms && cms.Page && cms.Page.smart_phone) {
    config.toolbar = [
      { name: 'styles',      items : [ 'Format' ] },
      { name: 'basicstyles', items : [ 'TextColor','Bold','Italic','Underline','Strike' ] },
      '/',
      { name: 'paragraph',   items : [ 'NumberedList','BulletedList','-','JustifyLeft','JustifyCenter','JustifyRight' ] },
      { name: 'links',       items : [ 'CmsLink','CmsUnlink' ] },
      { name: 'insert',      items : [ 'Image' ] }
    ];
  } else {
    config.toolbar = [
      { name: 'clipboard',   items : [ 'Cut','Copy','Paste','PasteText','PasteFromWord','-','Undo','Redo' ] },
      { name: 'styles',      items : [ 'Format' ] },
      { name: 'insert',      items : [ 'Image','Table','HorizontalRule','Youtube','Audio','Video' ] },
      { name: 'document',    items : [ 'Source','-','DocProps','-','Templates' ] },
      { name: 'tools',       items : [ 'Maximize' ] },
      '/',
      { name: 'basicstyles', items : [ 'TextColor','Bold','Italic','Strike','-','RemoveFormat' ] },
      { name: 'paragraph',   items : [ 'NumberedList','BulletedList','-','Outdent','Indent','-','Blockquote','-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock' ] },
      { name: 'links',       items : [ 'CmsLink','CmsUnlink','CmsAnchor' ] }
    ];
  }

  // 外部CSSを読み込み
  var css = [config.contentsCss];
  css.push(css[0].substring(0, css[0].lastIndexOf('/')+1) + 'file_icons.css');
  css.push(css[0].substring(0, css[0].lastIndexOf('/')+1) + 'cms_contents.css');
  config.contentsCss = css;

  // フォントサイズをパーセンテージに変更
  config.fontSize_sizes = '10px/71.53%;12px/85.71%;14px(標準)/100%;16px/114.29%;18px/128.57%;21px/150%;24px/171.43%;28px/200%';

  // フォーマットからh1などを除外
  config.format_tags = 'p;h2;h3;h4';

  // 使用するテンプレート
  config.templates_files = [ '/_common/js/ckeditor/plugins/templates/templates/cms_template.js' ];
  config.templates = 'cms';

  // インデント
  config.indentOffset = 1;
  config.indentUnit = 'em';

  // カラーコード設定
  config.colorButton_colors = 'ee0000,0000ff,008800,663399,D54300,000099,8F4D00,767676,e60066,0068ff,777c00,93008F,D13D6D,147AA3,000000,ffffff';

  // その他のカラーコード選択を許可
  config.colorButton_enableMore = true;

  // テンプレート内容の置き換えしない
  config.templates_replaceContent = false;

  // プラグイン
  config.extraPlugins = 'youtube,audio,video,wordcount,zomekilink';

  // tagの許可
  config.allowedContent = {
    $1: { // Use the ability to specify elements as an object.
      elements: CKEDITOR.dtd,
      attributes: true,
      styles: true,
      classes: true
    }
  };
  // table廃止・非推奨属性入力不可
  config.disallowedContent = 'font;table[summary,height,cellspacing,cellpadding,align]{height};script;*[on*];*[data-*]';

  // Wordからの貼付で装飾を削除する
  config.pasteFromWordRemoveFontStyles = true;
  config.pasteFromWordRemoveStyles = true;

  // wordcountプラグイン
  config.wordcount = {
    showParagraphs: false,
    showWordCount: false,
    showCharCount: true,
    countSpacesAsChars: true,
    countHTML: true
  };
};

CKEDITOR.on('instanceReady', function(ev) {
  var rules = {
    elements: {
      a: function(element) {
        // hrefからjavascriptプロトコルを除去
        var href = element.attributes.href;
        if (href && href.match(/^javascript:/i)) {
          element.attributes['data-cke-saved-href'] = '';
        }
      }
    }
  };
  ev.editor.dataProcessor.htmlFilter.addRules(rules);
  ev.editor.dataProcessor.dataFilter.addRules(rules);
});

CKEDITOR.on('dialogDefinition', function(ev){
  var dialogName = ev.data.name;
  var dialogDefinition = ev.data.definition;
  // テーブル幅のデフォルト値を削除
  if (dialogName == 'table') {
    var infoTab = dialogDefinition.getContents('info');
    txtWidth = infoTab.get('txtWidth');
    txtWidth['default'] = '';
  }
});

// スタイルの設定
CKEDITOR.stylesSet.add('my_styles', [
  // Block-level styles
  { name: '枠線', element: 'p', styles: { 'border': '1px solid #999' , 'padding' : '10px' } },

  // Inline styles
  { name: '強調（赤文字）', element: 'span', styles: { 'color': '#e00' } }
]);

CKEDITOR.config.stylesSet = 'my_styles';
CKEDITOR.config.coreStyles_strike = { element : 'del' };
CKEDITOR.config.coreStyles_underline = { element : 'ins' };
