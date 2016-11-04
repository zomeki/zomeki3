/**
 * jquery.naviRollover.js
 * Description: 現在のページが属するカテゴリーのボタンにクラスをつけたり画像を反転させたりするjQueryプラグイン
 * Version: 1.5.0
 * Author: Takashi Kitajima
 * Autho URI: http://2inc.org
 * created: Jun 6, 2011
 * modified : December 9, 2015
 * License: GPL2
 *
 * Copyright 2012 Takashi Kitajima (email : inc@2inc.org)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License, version 2, as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 *
 * 指定するナビゲーションの最初のリンクは必ずトップページ（各ページの上位階層か
 * 同階層のindex）である必要があります。
 *
 * 判別後の処理の種類
 * type : html
 *      リンクにclassを付与
 * type : image
 *      リンク内の画像名が *_n.ext のものを、*_r.ext に置き換える
 */
( function( $ ) {
	$.fn.naviRollOver = function( config ) {
		var navi = this;
		var defaults = {
			type     : 'html',		// タイプ(html or image)
			keepFlg  : false,		// 見つけても処理続けるか
			tag      : 'ul li a',	// 処理をするhtmlタグを指定
			className: 'cur',		// カレントリンクに付与されるclass名
			firstStrictCheck: true,	// 最初の要素を厳密にチェックするか
			hashStrictCheck: false   // # つきの URL を別 URL として扱うか
		};
		var config = $.extend( defaults, config );

		var url = removeIndex( location );
		return this.each( function() {
			var naviArr = navi.find( config.tag );
			$.each( naviArr, function( i, e ) {
				var atag = e;
				if ( typeof atag.hostname === 'undefined' ) {
					atag = $( atag ).find( 'a' ).get( 0 );
					if ( atag.hostname === 'undefined' )
						return true;
				}
				if ( atag.hostname === location.hostname ) {
					var navUrl = removeIndex( atag );
					if ( config.firstStrictCheck === true ) {
						if ( url === navUrl || ( url.indexOf( navUrl ) === 0 && i !== 0 ) ) {
							return changeCurrentItem( e );
						}
					} else if ( config.firstStrictCheck === false ) {
						if ( url.indexOf( navUrl ) === 0 ) {
							return changeCurrentItem( e );
						}
					}
				}
			} );
		} );

		function changeCurrentItem( e ) {
			switch ( config.type ) {
				case 'html' :
					$( e ).addClass( config.className );
					break;
				case 'image' :
					var currentImg = $( e ).find( 'img' ).attr( 'src' ).split( '_n\.', 2 );
					var newCurrentImgSrc = currentImg[0] + "_r." + currentImg[1];
					$( e ).find( 'img' ).attr( { src: newCurrentImgSrc } );
					break;
			}
			return config.keepFlg;
		}

		function removeIndex( url ) {
			if ( config.hashStrictCheck ) {
				var hash = url.hash;
			}
			url = url.pathname;
			if ( url.match( /^(.+\/)index\.([^\/]+)$/i ) ) {
				url = RegExp.$1;
			}
			if ( url.substring( 0, 1 ) != '/' ) {
				url = '/' + url;
			}
			if ( hash ) {
				url = url + hash;
			}
			return url;
		}
	};
} )( jQuery );
