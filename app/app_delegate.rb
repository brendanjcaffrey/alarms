class AppDelegate
  attr_accessor :status_menu

  def applicationDidFinishLaunching(notification)
    @app_name = NSBundle.mainBundle.infoDictionary['CFBundleDisplayName']

    @status_menu = NSMenu.new

    @status_item = NSStatusBar.systemStatusBar.statusItemWithLength(NSVariableStatusItemLength).init
    @status_item.setMenu(@status_menu)
    @status_item.setHighlightMode(true)
    @status_item.setTitle(@app_name)

    @status_menu.addItem createMenuItem("About #{@app_name}", 'orderFrontStandardAboutPanel:')
    @status_menu.addItem createMenuItem("Custom Action", 'pressAction')
    @status_menu.addItem createMenuItem("Quit", 'terminate:')

    url = NSURL.URLWithString('ws://127.0.0.1:6437')
    @socket = SRWebSocket.alloc.initWithURLRequest(NSURLRequest.requestWithURL(url))
    @socket.delegate = self
    @socket.open
  end

  def createMenuItem(name, action)
    NSMenuItem.alloc.initWithTitle(name, action: action, keyEquivalent: '')
  end

  def pressAction
    alert = NSAlert.alloc.init
    alert.setMessageText "Action triggered from status bar menu"
    alert.addButtonWithTitle "OK"
    alert.runModal
  end

  def webSocketDidOpen(webSocket)
    data = '{"enableGestures":true}'
    @socket.send(data)
  end

  def webSocket(webSocket, didReceiveMessage:message)
    error_ptr = Pointer.new(:object)
    parsed = message.description.objectFromJSONStringWithParseOptions(JKParseOptionValidFlags, error:error_ptr)

    if parsed.nil?
      error = error_ptr[0]
      puts error.userInfo[NSLocalizedDescriptionKey]
    else
      p parsed['gestures'] unless parsed['gestures'].nil? or parsed['gestures'].empty?
    end
  end

  def webSocket(webSocket, didFailWithError:error)
  end

  def webSocket(webSocket, didCloseWithCode:code,reason:reason)
  end
end
