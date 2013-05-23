$ = jQuery

if document.body.style['-webkit-mask-repeat'] isnt undefined
    ($ 'html').addClass 'cssmasks'
else
    ($ 'html').addClass 'no-cssmasks'

tabTemplate = '''
    <div class="chrome-tab">
        <div class="chrome-tab-favicon"></div>
        <div class="chrome-tab-title"></div>
        <div class="chrome-tab-close"></div>
        <div class="chrome-tab-curves">
            <div class="chrome-tab-curve-left-shadow2"></div>
            <div class="chrome-tab-curve-left-shadow1"></div>
            <div class="chrome-tab-curve-left"></div>
            <div class="chrome-tab-curve-right-shadow2"></div>
            <div class="chrome-tab-curve-right-shadow1"></div>
            <div class="chrome-tab-curve-right"></div>
        </div>
    </div>
'''

defaultNewTabData =
    title: 'New Tab'
    favicon: 'http://g.etfv.co/http://www.keio.ac.jp/'
    data: {}

chromeTabs =
    init: (options) ->
        #console.log '[debug chromeTabs.init] options', options # =>Object {$shell: b.fn.b.init[0], minWidth: 45, maxWidth: 180}

        $.extend options.$shell.data(), options

        console.log '[debug chromeTabs.init] options', options # =>Object {$shell: b.fn.b.init[0], minWidth: 45, maxWidth: 180}
        #console.log '[debug chromeTabs.init] options.data()', options.data() # =>Uncaught TypeError: Object #<Object> has no method 'data'
        console.log '[debug chromeTabs.init] options.$shell', options.$shell # =>[prevObject: b.fn.b.init[1], context: document, selector: ".chrome-tabs-shell", jquery: "1.9.1", constructor: function…]
        #console.log '[debug chromeTabs.init] options.$shell.minWidth', options.$shell.minWidth # =>undifined
        console.log '[debug chromeTabs.init] options.minWidth', options.minWidth # =>

        options.$shell.find('.chrome-tab').each ->
            $(@).data().tabData = { data: {} }

        render = ->
            chromeTabs.render options.$shell

        ($ window).resize render #イベントハンドラの登録(ウィンドウリサイズがフック)
        render()

    render: ($shell) ->
        chromeTabs.fixTabSizes $shell
        chromeTabs.fixZIndexes $shell
        chromeTabs.setupEvents $shell
        chromeTabs.setupSortable $shell
        $shell.trigger 'chromeTabRender'

    setupSortable: ($shell) ->
        $tabs = $shell.find '.chrome-tabs'

        $tabs.sortable
            axis: 'x'
            tolerance: 'pointer'
            start: (e, ui) ->
                chromeTabs.fixZIndexes $shell
                if not ($ ui.item).hasClass 'chrome-tab-current'
                    $tabs.sortable 'option', 'zIndex',  ($ ui.item).data().zIndex
                else
                    $tabs.sortable 'option', 'zIndex',  $tabs.length + 40
            stop: (e, ui) ->
                chromeTabs.setCurrentTab $shell, ($ ui.item)

    fixTabSizes: ($shell) ->
        #すべてのタブを配列に格納
        $tabs = $shell.find '.chrome-tab'
        margin = (parseInt($tabs.first().css('marginLeft'), 10) + parseInt($tabs.first().css('marginRight'), 10)) or 0
        #Chromeタブ描画領域の全体幅から50とマージンを除く
        width = $shell.width() - 50
        width = (width / $tabs.length) - margin

        console.log '[debug fixTabSizes] $shell', $shell
        console.log '[debug fixTabSizes] $shell.data()', $shell.data()
        console.log '[debug fixTabSizes] $shell.minWidth', $shell.minWidth ##

        #ここで計算した1タブあたりでとりうる最大幅(初期化時に指定された最小幅以上最大幅以内で)を計算
        #width = Math.max($shell.data().minWidth, Math.min($shell.data().maxWidth, width))
        width = Math.max($shell.minWidth, Math.min($shell.maxWidth, width))
        #cssをセット
        $tabs.css width: width

    fixZIndexes: ($shell) ->
        #すべてのタブを選択
        $tabs = $shell.find '.chrome-tab'
        $tabs.each (i) ->
            $tab = $ @
            zIndex = $tabs.length - i
            zIndex = $tabs.length + 40 if $tab.hasClass 'chrome-tab-current' #current対応
            $tab.css
                zIndex: zIndex
            $tab.data
                zIndex: zIndex

    setupEvents: ($shell) ->
        $shell.unbind('dblclick').bind 'dblclick', ->
            chromeTabs.addNewTab $shell

        $shell.find('.chrome-tab').each ->
            $tab = $ @

            $tab.unbind('click').click ->
                chromeTabs.setCurrentTab $shell, $tab

            $tab.find('.chrome-tab-close').unbind('click').click ->
                chromeTabs.closeTab $shell, $tab

    addNewTab: ($shell, newTabData) ->
        $newTab = $ tabTemplate

        console.log '[debug addNewTab] $ tabTemplate: ', $ tabTemplate
        console.log '[debug addNewTab] $newTab: ', $newTab
        console.log '[debug addNewTab] newTabData: ', newTabData

        $shell.find('.chrome-tabs').append $newTab
        tabData = $.extend true, {}, defaultNewTabData, newTabData
        #$.extend([deep], target, object1, [objectN])
        # ※targetに{}を指定した場合は上書きせず, 拡張結果オブジェクトを返す

        ###debug###
        console.log '[debug addNewTab] $shell: ', $shell
        console.log '[debug addNewTab] $newTab: ', $newTab
        console.log '[debug addNewTab] defaultNewTabData: ', defaultNewTabData
        console.log '[debug addNewTab] tabData: ', tabData

        chromeTabs.updateTab $shell, $newTab, tabData
        chromeTabs.setCurrentTab $shell, $newTab

    setCurrentTab: ($shell, $tab) ->
        $shell.find('.chrome-tab-current').removeClass 'chrome-tab-current'
        $tab.addClass 'chrome-tab-current'
        chromeTabs.render $shell

    closeTab: ($shell, $tab) ->
        if $tab.hasClass('chrome-tab-current') and $tab.prev().length
            chromeTabs.setCurrentTab $shell, $tab.prev()
        $tab.remove()
        chromeTabs.render $shell

    updateTab: ($shell, $tab, tabData) ->
        console.log '[debug] tabData: ', tabData
        #console.log '[debug] tabData.title: ', tabData.title

        $tab.find('.chrome-tab-title').html tabData.title
        $tab.find('.chrome-tab-favicon').css backgroundImage: "url('#{tabData.favicon}')"
        $tab.data().tabData = tabData

window.chromeTabs = chromeTabs










