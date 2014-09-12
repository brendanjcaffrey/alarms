class AppDelegate
  attr_accessor :status_menu

  def applicationDidFinishLaunching(notification)
    @app_name = NSBundle.mainBundle.infoDictionary['CFBundleDisplayName']
    @status_menu = NSMenu.new

    @status_item = NSStatusBar.systemStatusBar.statusItemWithLength(NSVariableStatusItemLength).init
    @status_item.setMenu(@status_menu)
    @status_item.setHighlightMode(true)
    @status_item.setTitle(@app_name)

    defaults = NSUserDefaults.standardUserDefaults
    if defaults.objectForKey('alarms') == nil
      # TODO make this a blank string eventually
      defaults.setObject("201501011005\n201501011551", forKey:'alarms')
    end

    @collection = AlarmCollection.unserialize(defaults.objectForKey('alarms'))
    @collection.alarms.each do |alarm|
      @status_menu.addItem create_alarm_item(alarm)
    end

    @status_menu.addItem NSMenuItem.separatorItem
    @status_menu.addItem create_menu_item('Add Alarm...', 'add_alarm')
    @status_menu.addItem create_menu_item("About #{@app_name}", 'orderFrontStandardAboutPanel:')
    @status_menu.addItem create_menu_item('Quit', 'terminate:')
  end

  def add_alarm
    alert = NSAlert.alloc.init
    alert.setMessageText 'Add alarm action triggered from status bar menu'
    alert.addButtonWithTitle 'OK'
    alert.runModal
  end

  def alarm(menu_item)
    puts 'alarm tapped in menu: ' + menu_item.representedObject.inspect
  end

  private

  def create_menu_item(name, action)
    NSMenuItem.alloc.initWithTitle(name, action:action, keyEquivalent:'')
  end

  def create_alarm_item(alarm)
    item = NSMenuItem.alloc.initWithTitle(alarm_string(alarm), action:'alarm:', keyEquivalent:'')
    item.setRepresentedObject(alarm)
    item
  end

  def alarm_string(alarm)
    date = alarm.to_menu_date
    time = alarm.to_menu_time

    date + ' at ' + time
  end
end
