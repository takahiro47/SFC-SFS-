#use strict;
#use warnings;

$ ->

  #Chrome extension settings
  setInitSaveData = (data) ->
    if !getSaveData()
      setSaveData data
  getSaveData = ->
    if localStorage['data'] is undefined
      return false;
    return JSON.parse localStorage['data']
  setSaveData = ->
    localStorage['data'] = JSON.stringify data
  #set data
  setInitSaveData
    username: 't11593tt'
    password: ''

  #Chrome Tabs
  DEBUG = true
  $chromeTabsContainerShell = $ '.chrome-tabs-shell'
  initChromeTab = (currentPageName = '履修授業') ->
    chromeTabs.init
      $shell: $chromeTabsContainerShell
      minWidth: 45
      maxWidth: 180
    chromeTabs.addNewTab $chromeTabsContainerShell,
      favicon: 'http://g.etfv.co/http://www.keio.ac.jp/'
      title: currentPageName #'New Tab'
      data:
        timeAdded: +new Date()
    $chromeTabsContainerShell.bind 'chromeTabRender', ->
      $currentTab = $chromeTabsContainerShell.find '.chrome-tab-current' #Search current tab
      if $currentTab.length and window['console'] and console.log #and DEBUG
        console.log '[CurrentTab info] index:', $currentTab.index(), ', title:', $.trim($currentTab.text()), ', data:', $currentTab.data('tabData').data() if DEBUG
    registTabLink()
  registTabLink = -> #授業ページをChromeタブで開く
    ($ document).on 'click', 'a[href*="s_class_top.cgi"]', (e) ->
      $this = ($ @)
      #遷移なし
      e.preventDefault()
      #タブ追加
      chromeTabs.addNewTab $chromeTabsContainerShell,
        favicon: 'http://g.etfv.co/http://www.keio.ac.jp/'
        title: $this.text()
        data:
          timeAdded: +new Date()

  #SFCSFS Plugins
  version = '0.0.11'
  currentUri = ''
  token = []
  methods = {
    init: (options) ->
      console.log "init: called." if DEBUG
      console.log options if DEBUG
      #initialize
      methods.start()
      #assign event
      methods.assignEventHandlers()
    done: ->
      console.log "done: called." if DEBUG
    assignEventHandlers: ->
      #methods.registPushStateEvent()
      # methods.registTabLink()
    alert: (data) ->
      console.log "alert: called." if DEBUG
      alert data
    setCurrentUri: ->
      console.log "setCurrentUri: called." if DEBUG
      currentUri = ($ location).attr 'href'
    getCurrentUri: (update = false) ->
      if update or (currentUri is '')
        methods.setCurrentUri()
      else
        return currentUri
      #chrome.tabs.getSelected(window.id, function(tab){
      #  var url = document.createTextNode(tab.url); //tab.url = 開いているタブのURL
      #  document.getElementById('url').appendChild(url);
      #});
      #return url;
    getUrlVars: ->
      console.log "getUrlVars: called." if DEBUG
      #URL = window.location.href
      vars = []
      hash = []
      hashes = window.location.href.slice(window.location.href.indexOf('?')+1).split('&')
      ### DEBUG
      console.log window.location.href.slice(window.location.href.indexOf('?')+1)
      console.log window.location.href.slice(window.location.href.indexOf('?')+1).split('&')
      ###
      for i in [0..hashes.length-1] #for(var i=0; i<hashes.length; i++) {
        hash = hashes[i].split('=')
        vars.push hash[0]
        vars[hash[0]] = hash[1]
      vars['term'] = '2013s'
      vars['fix']  = '1'
      vars['type'] = 's'
      vars['mode'] = '0'
      return vars
    setToken: ->
      console.log "setToken: called." if DEBUG
      token = methods.getUrlVars()
    checkLoginStatus: (loginned = false) ->
      console.log "checkLoginStatus: called." if DEBUG
      ###
        when
          'https://vu8.sfc.keio.ac.jp/sfc-sfs/',
          'https://vu8.sfc.keio.ac.jp/sfc-sfs/index.cgi',
          'https://vu8.sfc.keio.ac.jp/sfc-sfs/login.cgi',
          'https://vu9.sfc.keio.ac.jp/sfc-sfs/'
      ###
      matchArr = currentUri.match /^(https?):\/\/vu(8|9).sfc.keio.ac.jp\/sfc-sfs\/((index|login)\.cgi)?/i
      if (matchArr[1] is 'https')
        if matchArr[4] is 'login'
          loginned = false
          console.log "You are now login process!" if DEBUG
        else if matchArr[4] is 'index' || matchArr[4]?
          loginned = false
          console.log "You are not loginned!" if DEBUG
        else
          loginned = true
          console.log "You are loginned!" if DEBUG
      else
        loginned = true
        console.log "You are known status!" if DEBUG
      return loginned
    start: ->
      console.log "start: called." if DEBUG
      methods.setCurrentUri()
      methods.setToken()
      #TODO トップページの場合は自動ログインを適用
      if ($ 'input[type="text"]').val() isnt '' and ($ 'input[type="password"]').val() isnt ''
        ($ 'input[type="submit"]').click()
      #処理の開始
      if methods.checkLoginStatus() ##TODO Loginned => do all things.
        console.log "start: loginned." if DEBUG
        #Re-build HTML4
        methods.htmlStructure()
        #Create chrome tab
        methods.createChromeTab()
        #Create schedule tab
        methods.loadScheduleTab()

        #Regist event handler
        methods.assignEventHandlers()
      else ##Not loginned
        console.log "start: not loginned." if DEBUG
        #TODO
      methods.done()
    htmlStructure: ->
      console.log "htmlStructure: called." if DEBUG
      #Erase disuse <td> obj(box-line and so on)
      ($ 'td[width~="1"], td[bgcolor~="#8ba1bd"], td[width~="14"]').remove()
      #Erase disuse <img> line
      ($ 'img[src$="page_top.gif"], img[src$="page_top_l.gif"], img[src$="page_bottom.gif"]').closest('table').remove()
      #Format HTML4(root)
      ($ 'body > table').each ->
        ($ @).wrap('<div class="container"></div>');
      ($ '.container:first-child').addClass('header-container')
      ($ '#footer').closest('.container').addClass('footer-container')
      #Initialize headerNavi
      methods.initHeaderNavi()
      #Initialize loader
      methods.initLoader()
      #Initialize content-article
      $article = ($ 'td[width="790"]')
      $article.closest('.container').before '<div class="container article-container"><div class="article"></div></div>'
      ($ '.article').append $article.html()
      $article.closest('.container').remove()
      ##Initialize Schedule
      methods.initSchedule()
    initLoader: ->
      console.log "createLoader: called." if DEBUG
      ($ "td[width~='350']").after("<td class='loader alpha0'></td>")
    startLoader: ->
      console.log "startLoader: called." if DEBUG
      ($ ".loader").removeClass('alpha1').addClass('alpha0')
    stopLoader: ->
      console.log "stopLoader: called." if DEBUG
      ($ ".loader").removeClass('alpha0').addClass('alpha1')
    initHeaderNavi: ->
      console.log "headerNaviInitial: called." if DEBUG
      #Create header navi
      ($ '.header-container').prepend ->
        sfsBaseURL = '//vu8.sfc.keio.ac.jp/sfc-sfs/portal_s/s0'
        tokenSet = '?id='+token['id']+'&amp;type='+token['type']+'&amp;mode='+token['mode']+'&amp;lang='+token['lang']
        items = ['cource', 'plan', 'mentor', 'graduate']
        elm = ($ '<div class="header-navi"></div>')
        li = []

        li.push '<ul class="header-navi-items clearfix">'
        for i in [1..4]
          li.push '<li class="header-navi-item item-'+items[i-1]+'"><a href="'+sfsBaseURL+i+'.cgi'+tokenSet+'"></a></li>'
        li.push '</ul>'

        return elm.append(li.join(""));
      #Mark current view item on header navi
      if currentUri.match(/s01\.cgi/g)
        ($ '.item-cource').addClass('item-current')
      else if currentUri.match(/s02\.cgi/g)
        ($ '.item-plan').addClass('item-current')
      else if currentUri.match(/s03\.cgi/g)
        ($ '.item-mentor').addClass('item-current')
      else if currentUri.match(/s04\.cgi/g)
        ($ '.item-graduate').addClass('item-current')
    changeHeaderNavi: (name) ->
      console.log "headerNaviChange: called." if DEBUG
      #TODO
    initSchedule: ->
      console.log "initSchedule: called." if DEBUG
      $target0 = ($ '.myschedule')
      $target1 = ($ '.mylist')
      elm = '''
          <div class="btn-toolbar">
            <div class="btn-group">
              <a class="btn" href="#"><i class="icon-align-left"></i></a>
              <a class="btn" href="#"><i class="icon-align-center"></i></a>
              <a class="btn" href="#"><i class="icon-align-right"></i></a>
              <a class="btn" href="#"><i class="icon-align-justify"></i></a>
            </div>
          </div>'''
      $target0.before elm if $target0[0] and $target1[0]
    createChromeTab: (currentPageName = '履修授業') ->
      console.log "chromeTabCreate: called." if DEBUG
      ($ '.header-container').append("""
        <div class="chrome-tabs-shell-container">
          <div class='chrome-tabs-shell'>
            <div class='chrome-tabs'>
              <div class='chrome-tab'>
                <div class='chrome-tab-favicon'></div>
                <div class='chrome-tab-title'>My時間割</div>
                <div class='chrome-tab-curves'>
                  <div class='chrome-tab-curve-left-shadow2'></div>
                  <div class='chrome-tab-curve-left-shadow1'></div>
                  <div class='chrome-tab-curve-left'></div>
                  <div class='chrome-tab-curve-right-shadow2'></div>
                  <div class='chrome-tab-curve-right-shadow1'></div>
                  <div class='chrome-tab-curve-right'></div>
                </div>
              </div>
              <div class='chrome-tab chrome-tab-current'>
                <div class='chrome-tab-favicon'></div>
                <div class='chrome-tab-title'>#{currentPageName}</div>
                <div class='chrome-tab-close'></div>
                <div class='chrome-tab-curves'>
                  <div class='chrome-tab-curve-left-shadow2'></div>
                  <div class='chrome-tab-curve-left-shadow1'></div>
                  <div class='chrome-tab-curve-left'></div>
                  <div class='chrome-tab-curve-right-shadow2'></div>
                  <div class='chrome-tab-curve-right-shadow1'></div>
                  <div class='chrome-tab-curve-right'></div>
                </div>
              </div>
            </div>
            <div class='chrome-shell-bottom-bar'></div>
          </div>
        </div>
      """)
      #Initialize chrome tab
      initChromeTab()
    ###
    initChromeTab: (currentPageName = '履修授業') ->
        console.log "chromeTabInitial: called." if DEBUG

        chromeTabs.init
          $shell: $chromeTabsContainerShell
          minWidth: 45
          maxWidth: 180
        chromeTabs.addNewTab $chromeTabsContainerShell,
          favicon: 'http://g.etfv.co/http://www.keio.ac.jp/'
          title: currentPageName #'New Tab'
          data:
            timeAdded: +new Date()
        $chromeTabsContainerShell.bind 'chromeTabRender', ->
          $currentTab = $chromeTabsContainerShell.find '.chrome-tab-current' #Search current tab
          if $currentTab.length and window['console'] and console.log #and DEBUG
            console.log '[CurrentTab info] index:', $currentTab.index(), ', title:', $.trim($currentTab.text()), ', data:', $currentTab.data('tabData').data() if DEBUG
    registTabLink: -> #授業ページをChromeタブで開く
      ($ document).on 'click', 'a[href*="s_class_top.cgi"]', (e) ->
        $this = ($ @)
        #遷移なし
        e.preventDefault()
        #タブ追加
        chromeTabs.addNewTab $chromeTabsContainerShell,
          favicon: 'http://g.etfv.co/http://www.keio.ac.jp/'
          title: $this.text()
          data:
            timeAdded: +new Date()
    ###
    loadScheduleTab: ->
      console.log "loadScheduleTab: called." if DEBUG
      #TODO ここでは仮にタブではなくiframeに置き換え
      base = '//vu8.sfc.keio.ac.jp/sfc-sfs/sfs_class/student/'
      tokens = '?id='+token['id']+'&amp;term='+token['term']+'&amp;fix='+token['fix']+'&amp;lang='+token['lang'];
      ($ '#frame_set').after '<div class="myschedule">'
      ($ '.myschedule').load base+'view_timetable.cgi'+tokens+' table', null, (response, status, xhr) ->
        if status is "error"
          msg = "Sorry but there was an error: "
          ($ "#error").html (msg + xhr.status + " " + xhr.statusText)
      ($ '.myschedule').after '<div class="mylist">'
      ($ '.mylist').load base+'view_list.cgi'+tokens+'#1 table', null, (response, status, xhr) ->
        if status is "error"
          msg = "Sorry but there was an error: ";
          ($ "#error").html (msg + xhr.status + " " + xhr.statusText)
      ($ '#frame_set').remove()
    ###registPushStateEvent: ->
      #_href: //同一ページのpushState二重投稿防止用
      pushTargetHtml5 = '.article'
      pushTargetHtml4 = 'td[width="790"]'
      #初期ページのタイトルとHTMLを定義
      _default = {
        title: document.title,
        content: ($ pushTargetHtml5).html()
      };
      #PushState
      pushStateToggle = ->
        methods.startLoader() #show loader
        #
        request = $(@).attr "href"
        url = location.host
        thisProt = location.protocol
        relativePath = request.replace(thisProt,"").replace("//","").replace(url,"") #相対パス生成
        if relativePath is ""
          relativePath = "/" #相対パスが空だったときはスラッシュを代入

        #Callback
        after = ->
          methods.stopLoader() #hide loader
        #Refresh
        refreshInfo = ->
          if _href isnt request
            if window.history.pushState #pushStateが使えるブラウザなら
              history.pushState "", "", relativePath #pushStateでアドレスバーを変更
              #pageTitle = ($ "h1").text() #get page title as New page title
              #($ "title").text pageTitle #Change page title
              _href is request
            else #if is NOT supported pushState, open normaly
              window.location is request

          methods.registPushStateEvent.pushStateToggle.after() #afterを実行
        displayContent = ->
          #($ "html,body,td[width='350']").animate {scrollTop: 0}, 1000 #画面位置を上に戻す
          methods.registPushStateEvent.pushStateToggle.refreshInfo()
        loadContent = ->
          ($ pushTargetHtml5).load request+" "+pushTargetHtml4, methods.registPushStateEvent.pushStateToggle.displayContent

        methods.registPushStateEvent.pushStateToggle.loadContent()

        if window.history and window.history.pushState
          #PushState(リンクボタン押下時挙動)
         ($ document).on 'click', pushTargetHtml5+' #navigation a', methods.registPushStateEvent.pushStateToggle
         ($ document).on 'click', pushTargetHtml5+' #navigation a', (e) -> e.preventDefault() #リンク遷移無効化
    ###
  };
  $.fn.sfcsfs = (method, config) ->
    options = $.extend({
      #Initialize with default config
      backgroundColor: '#F00'
    }, config)
    @.each ->
      $this = ($ @)
      $this.css({
        'background-color': options.backgroundColor
      })

      #Method calling logic
      if methods[method]
        methods[method].apply @, Array.prototype.slice.call arguments, 1
      else if typeof method == 'object' || !method
        methods.init.apply @, arguments
      else
        $.error 'Method ' + method + ' does not exist on jQuery.sfcsfs'

  #SFC-SFSプラグインの実行
  ($ window).sfcsfs({
    'background-color': '#F00'
  })

  ###授業ページをChromeタブで開く
  ($ document).on 'click', 'a[href*="s_class_top.cgi"]', (e) ->
    $this = ($ @)
    #遷移なし
    e.preventDefault()
    #タブ追加
    chromeTabs.addNewTab $chromeTabsContainerShell,
      favicon: 'http://g.etfv.co/http://www.keio.ac.jp/'
      title: $this.text()
      data:
        timeAdded: +new Date()

  #授業ページをChromeタブで開く old
  ($ document).on 'click', '.myschedule td[bgcolor="#eeeeee"] a', (e) ->
    $this = ($ @)
    #遷移なし
    e.preventDefault()
    #タブ追加
    chromeTabs.addNewTab $chromeTabsContainerShell,
      favicon: 'http://g.etfv.co/http://www.keio.ac.jp/'
      title: $this.text()
      data:
        timeAdded: +new Date()
  ###
