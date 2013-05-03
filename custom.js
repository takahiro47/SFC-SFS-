//use strict;
//use warnings;

var setInitSaveData = function(data) {
	if(!getSaveData()) setSaveData(data);
};
var getSaveData = function() {
	if(localStorage['data']==undefined) return false;
	return JSON.parse(localStorage['data']);
};
var setSaveData = function(data) {
	localStorage['data'] = JSON.stringify(data);
};

setInitSaveData({css: true});



$(function() {
	
	/* =GET
	 *------------------------------------------------------ */
	function getUrlVars() {
		var vars = [], hash; 
		var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&'); 
		for(var i = 0; i < hashes.length; i++) { 
			hash = hashes[i].split('='); 
			vars.push(hash[0]); 
			vars[hash[0]] = hash[1]; 
		} 
		return vars;
	}
	var token = getUrlVars();
	token['term'] = '2013s';
	token['fix'] = '1';
	
	token['type'] = 's';
	token['mode'] = '0';
	
	
	/* =ログイン画面だった場合の対応
	 *------------------------------------------------------ */
	var current_uri = window.location.href, login_flag = false;
	if (current_uri == 'https://vu8.sfc.keio.ac.jp/sfc-sfs/' || current_uri == 'https://vu9.sfc.keio.ac.jp/sfc-sfs/') {
		login_flag = true;
	}
	if (login_flag) {
		
		/* =HTML整形
		 *------------------------------------------------------ */
		function html_arrange() {
			//不要td要素の排除
			$("td[width~='1'], td[bgcolor~='#8ba1bd'], td[width~='14']").remove();
			
			//枠の削除
			$("img[src$='page_top.gif']").closest('table').remove();
			$("img[src$='page_bottom.gif']").closest('table').remove();
			
			//HTML構成の整形
			$("body > table").each(function(){
				$(this).wrap('<div class="container"></div>');
			});
			$(".container:first-child").addClass('header-container');
			$('#footer').closest('.container').addClass('footer-container');
			
			//ヘッダメニューの生成
			$('.header-container').prepend(function() {
				var uri_base0 = '//vu8.sfc.keio.ac.jp/sfc-sfs/portal_s/s0', uri_base1 = '.cgi?id='+token['id']+'&amp;type='+token['type']+'&amp;mode='+token['mode']+'&amp;lang='+token['lang'];
				var items = ['cource', 'plan', 'mentor', 'graduate'];
				var elm = $('<div class="header-navi"></div>'), li = [];
				
				li.push('<ul class="header-navi-items clearfix">');
				for (var i=1; i<=4; i++) {
					li.push('<li class="header-navi-item item-'+items[i-1]+'"><a href="'+uri_base0+i+uri_base1+'"></a></li>');
				}
				li.push('</ul>');
				
				return elm.append(li.join(""));
			});
			
			//ローダの追加
			$("td[width~='350']").after("<td class='loader alpha0'></td>");
			
			//メインコンテンツの整形
			$article = $('td[width="790"]');
			$article.closest('.container').before('<div class="container article-container"><div class="article"></div></div>');
			$('.article').append( $article.html() );
			$article.closest('.container').remove();
			
			return true;
		}
		html_arrange();
		
		
		/* =ヘッダナビのcurrentを変色
		 *------------------------------------------------------ */
		if (current_uri.match(/s01\.cgi/g)) $('.item-cource').addClass('item-current')
		else if (current_uri.match(/s02\.cgi/g)) $('.item-plan').addClass('item-current')
		else if (current_uri.match(/s03\.cgi/g)) $('.item-mentor').addClass('item-current')
		else if (current_uri.match(/s04\.cgi/g)) $('.item-graduate').addClass('item-current')
		
		
		/* =Chrome Tab Initial
		 *------------------------------------------------------ */
		$('.header-container').append([
			'<div class="chrome-tabs-shell">\
				<div class="chrome-tabs">\
					<div class="chrome-tab">\
						<div class="chrome-tab-favicon"></div>\
						<div class="chrome-tab-title">My時間割</div>\
						<div class="chrome-tab-curves">\
							<div class="chrome-tab-curve-left-shadow2"></div>\
							<div class="chrome-tab-curve-left-shadow1"></div>\
							<div class="chrome-tab-curve-left"></div>\
							<div class="chrome-tab-curve-right-shadow2"></div>\
							<div class="chrome-tab-curve-right-shadow1"></div>\
							<div class="chrome-tab-curve-right"></div>\
						</div>\
					</div>\
					<div class="chrome-tab chrome-tab-current">\
						<div class="chrome-tab-favicon"></div>\
						<div class="chrome-tab-title">履修授業</div>\
						<div class="chrome-tab-close"></div>\
						<div class="chrome-tab-curves">\
							<div class="chrome-tab-curve-left-shadow2"></div>\
							<div class="chrome-tab-curve-left-shadow1"></div>\
							<div class="chrome-tab-curve-left"></div>\
							<div class="chrome-tab-curve-right-shadow2"></div>\
							<div class="chrome-tab-curve-right-shadow1"></div>\
							<div class="chrome-tab-curve-right"></div>\
						</div>\
					</div>\
				</div>\
				<div class="chrome-shell-bottom-bar"></div>\
			</div>'
		].join(""));
		
		
		
		/* =Chromeタブ 初期化
		 *------------------------------------------------------ */
		var $chromeTabsExampleShell = $('.chrome-tabs-shell')
		chromeTabs.init({
			$shell: $chromeTabsExampleShell,
			minWidth: 100,
			maxWidth: 960
		});
		/*
		chromeTabs.addNewTab($chromeTabsExampleShell, {
			favicon: 'http://g.etfv.co/http://www.keio.ac.jp/',
			title: 'New Tab',
			data: {
				timeAdded: +new Date()
			}
		});
		*/
		$chromeTabsExampleShell.bind('chromeTabRender', function(){
			var $currentTab = $chromeTabsExampleShell.find('.chrome-tab-current');
			if ($currentTab.length && window['console'] && console.log) {
				//console.log('Current tab index', $currentTab.index(), 'title', $.trim($currentTab.text()), 'data', $currentTab.data('tabData').data);
			}
		});
		
		
		/* =My時間割タブの読み込み
		 *------------------------------------------------------ */
		$('#frame_set').after('<div class="myschedule"></div>');
		$('.myschedule').load("//vu8.sfc.keio.ac.jp/sfc-sfs/sfs_class/student/view_timetable.cgi?id="+token['id']+'&amp;term='+token['term']+'&amp;fix='+token['fix']+'&amp;lang='+token['lang']+' table',
			null,
			function(response, status, xhr) {
				if (status == "error") {
					var msg = "Sorry but there was an error: ";
					$("#error").html(msg + xhr.status + " " + xhr.statusText);
				}
			}
		);
		$('.myschedule').after('<div class="mylist"></div>')
		$('.mylist').load("//vu8.sfc.keio.ac.jp/sfc-sfs/sfs_class/student/view_list.cgi?id="+token['id']+'&amp;term='+token['term']+'&amp;fix='+token['fix']+'&amp;lang='+token['lang']+'#1 table',
			null,
			function(response, status, xhr) {
				if (status == "error") {
					var msg = "Sorry but there was an error: ";
					$("#error").html(msg + xhr.status + " " + xhr.statusText);
				}
			}
		);
		$('#frame_set').remove();
		
		
		/* =Pjax
		 *------------------------------------------------------ *
		var _target = "";
		var _trigger = "";
		$('#navigation').attr('data-pjax-navtop','1')
		if ($.support.pjax) {
			$(document).pjax('[data-pjax-navtop] a', 'table[width="853"]')
			$(document).on('click', '[data-pjax-navtop] a',function(e){ e.preventDefault(); });
		}
		$(document).on('pjax:send', function(){
			$(".loader").removeClass('alpha0').addClass('alpha1')
		})
		$(document).on('pjax:complete', function(){
			$(".loader").removeClass('alpha1').addClass('alpha0')
		})
		$(document).on('pjax:timeout', function(e) {
			e.preventDefault()
		})
		*/
		
		
		/* =HTML4 PushState
		 *------------------------------------------------------ */
		var _href; //同一ページのpushState二重投稿防止用
		var _target = '.article';
		//初期ページのタイトルとHTMLを定義
		var _default = { 
			title : document.title,
			content : $(_target).html()
		};
		//PushState
		var pushStateToggle = function(){
			$('.loader').removeClass('alpha0').addClass('alpha1'); //ローダを表示
			
			request = $(this).attr("href");
			url = location.host;
			thisProt = location.protocol;
			relativePath = request.replace(thisProt,"").replace("//","").replace(url,""); //相対パス生成
			if(relativePath == "") relativePath = "/"; //相対パスが空だったときはスラッシュを代入
			
			//Callback
			after = function(){
				$(".loader").removeClass('alpha1').addClass('alpha0'); //ローダー削除
			}
			//Refresh
			refreshInfo = function(){
				if (_href !== request) {
					if (window.history.pushState) { //pushStateが使えるブラウザなら
						history.pushState("", "", relativePath); //pushStateでアドレスバーを変更
						//pageTitle = $("h1").text(); //新しいページタイトルとしてh1を取得
						//$("title").text(pageTitle); //ページタイトルを変更
						_href = request;
					} else { //pushState対応してないなら、普通に開く
						window.location = request;
					}
				}
				after(); //afterを実行
			}
			displayContent = function(){
				//$("html,body,td[width='350']").animate({scrollTop: 0},1000); //画面位置を上に戻す
				refreshInfo();
			}
			loadContent = function(){
				$(_target).closest('td').load(request+" "+_target,displayContent);
			}
			loadContent();
		}
		if (window.history && window.history.pushState) {
			//PushState(リンクボタン押下時挙動)
			$(document).on('click', _target+' a', pushStateToggle);
			$(document).on('click', _target+' a', function(e){ e.preventDefault(); }); //リンク遷移無効化
		}
		
		
		
		
		
		/* =Chrome Tab Pointer
		 *------------------------------------------------------ *
		var originalBGplaypen = $("#playpen").css("background-color"),
			x, y, xy, bgWebKit, bgMoz, 
			lightColor = "rgba(255,255,255,0.75)",
			gradientSize = 100;
		var originalBG = $(".nav a").css("background-color");
		$('.nav li:not(".active") a')
			.mousemove(function(e) {
				x = e.pageX - this.offsetLeft;
				y = e.pageY - this.offsetTop;
				xy = x + " " + y;
				bgWebKit = "-webkit-gradient(radial, " + xy + ", 0, " + xy + ", 100, from(rgba(255,255,255,0.8)), to(rgba(255,255,255,0.0))), " + originalBG;
				bgMoz    = "-moz-radial-gradient(" + x + "px " + y + "px 45deg, circle, " + lightColor + " 0%, " + originalBG + " " + gradientSize + "px)";
				$(this)
					.css({ background: bgWebKit })
					.css({ background: bgMoz });
			}).mouseleave(function() {
				$(this).css({ background: originalBG });
			});
		});
		*/
		
	}
	
	var _getDOM = function(dirtyhtml) {
		var dom = $("<div/>").addClass("tmp"+Math.random()).css({display: "none", visiblity: "hidden"});
		$("body").append(dom.find("body"));
		dom.html(dirtyhtml);
		return dom;
	};
	var _getTitle = function(data) {
		return data.find("h3").text().split("\n")[1];
	};
	var _getHomework = function(data) {
		var ret = data.find("font[color=#cc0000]:contains(課題)").parent().parent().find("p");
		ret.find("a").removeAttr("href");
		ret.find(".en").remove();
		return ret;
	};
	var FC_Homework = function() {
		var noticeBox = $("<div/>");
		$(".noticeTitle").after(noticeBox);
		var status = $("<p/>").text("読み込み中...")
		noticeBox.append(status);
		var classes = $("[name=frame]").contents().find("td a");
		var class_urls = new Array();
		for (var i = 0; i < classes.length; i++) {
			class_urls.push($(classes[i]).attr("href"));
		}
		class_urls = $.unique(class_urls);
		
		var remain = class_urls.length;
		for (var j = 0; j < class_urls.length; j++) {
			$.ajax({type: "GET", url: class_urls[j], success: function(data) {
				data = _getDOM(data);
				var hw = _getHomework(data);
				hw = hw[hw.length-1];
				if(hw) noticeBox.append($("<p/>").addClass("ST_title").text(_getTitle(data))).append($(hw).addClass("ST_data"));
				status.text("読み込み中...残り"+--remain);
				if(remain == 0) status.remove();
			}});
		}
	};

	//セッション終了時移動
	if($("h3:contains(本セッションは終了しました)").size() > 0 || $("h3:contains(セッションがタイムアウトしました)").size() > 0) {
		location.href = $("a:contains(SFC-SFS トップページ)").attr("href");
	}
	
	//トップページ 自動ログイン
	if($("input[type=text]").val() != "" && $("input[type=password]").val()) {
		$("input[type=submit]").click();
	}

	/** 時間割(課題一覧機能) **/
	if(location.pathname == "/sfc-sfs/portal_s/s01.cgi") {
		var noticeTitle = $("<h4/>").addClass("one").text("課題一覧").addClass("noticeTitle");
		$("h4.one").before(noticeTitle);
		// noticeTitle.append($("<button/>").text("課題を取得").click(function() {
		// 	$(this).remove();
		// 	FC_Homework();
		// }));
		FC_Homework();
	}
	
	/** CSS適用 **
	if(getSaveData()['css'] && location.pathname != "/sfc-sfs/index.cgi") {
		$("head").append($("<link/>").attr({
			rel: "stylesheet",
			type: "text/css",
			href: chrome.extension.getURL("config.css")
		}));
	}
	*/
	
	/*
	$("body").append(
		$("<div/>").addClass("FT_customcss").text(getSaveData()['css']?"CSSをオフにする":"CSSをオンにする").click(function() {
			var sd = getSaveData();
			sd['css'] = !sd['css'];
			setSaveData(sd);
			location.reload();
		})
	)
	*/
})