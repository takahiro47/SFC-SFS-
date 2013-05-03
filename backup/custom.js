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

	/** セッション終了時移動 **/
	if($("h3:contains(本セッションは終了しました)").size() > 0 || $("h3:contains(セッションがタイムアウトしました)").size() > 0) {
		location.href = $("a:contains(SFC-SFS トップページ)").attr("href");
	}

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

	/** CSS適用 **/
	if(getSaveData()['css'] && location.pathname != "/sfc-sfs/index.cgi") {
		$("head").append($("<link/>").attr({
			rel: "stylesheet",
			type: "text/css",
			href: chrome.extension.getURL("sfs.css")
		}));
	}

	$("body").append(
		$("<div/>").addClass("FT_customcss").text(getSaveData()['css']?"CSSをオフにする":"CSSをオンにする").click(function() {
			var sd = getSaveData();
			sd['css'] = !sd['css'];
			setSaveData(sd);
			location.reload();
		})
	)
})