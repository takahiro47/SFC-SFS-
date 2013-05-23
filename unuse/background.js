var Background = Class.create({
	initialize: function(){
		this.assignEventHandlers();
	},
	assignEventHandlers: function(){
		//
	},
	getServerUrl: function(){
		return "http://ht.sfc.keio.ac.jp/~tsucchi/sfcsfs/";
	},
	getCurrentUrl: function(){
		chrome.tabs.getSelected(window.id, function(tab){
			var url = document.createTextNode(tab.url); //tab.url = 開いているタブのURL
			document.getElementById('url').appendChild(url);
		});
		return url;
		//return window.location.href;
	},
	getUrlVars: function(){
		var vars = [], hash;
		var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
		for(var i = 0; i < hashes.length; i++) {
			hash = hashes[i].split('=');
			vars.push(hash[0]);
			vars[hash[0]] = hash[1];
		} 
		vars['term'] = '2013s';
		vars['fix']  = '1';
		vars['type'] = 's';
		vars['mode'] = '0';
		return vars;
	},
	checkLoginStatus: function(){
		var login_flag = false;
		switch (this.getCurrentUrl()) {
			case 'https://vu8.sfc.keio.ac.jp/sfc-sfs/':
			case 'https://vu9.sfc.keio.ac.jp/sfc-sfs/':
				login_flag = true;
				break;
			default:
				login_flag = false;
		} //switch
		return login_flag;
	},
	htmlStructure: function(){
		
	},
	loadSchedule: function(callbacks){
		var url = 
	},
	
});
var bg = new background();
