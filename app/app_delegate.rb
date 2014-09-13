class AppDelegate
  attr_accessor :status_menu

  def applicationDidFinishLaunching(notification)
    defaults = NSUserDefaults.standardUserDefaults
    defaults.setObject('', forKey:'alarms') if defaults.objectForKey('alarms') == nil

    @collection = AlarmCollection.unserialize(defaults.objectForKey('alarms'))
    build_menu
  end

  def add_alarm
    @window = AlarmInfoController.alloc.init
    @window.showWindow(self)
    @window.window.orderFrontRegardless
  end

  def edit_alarm(menu_item)
    @window = AlarmInfoController.alloc.init_with_alarm(menu_item.representedObject)
    @window.showWindow(self)
    @window.window.orderFrontRegardless
  end

  private

  def build_menu
    @status_menu = NSMenu.new

    @status_item = NSStatusBar.systemStatusBar.statusItemWithLength(NSVariableStatusItemLength).init
    @status_item.setMenu(@status_menu)
    @status_item.setHighlightMode(true)
    @status_item.setTitle('Alarms')
    fill_menu
  end

  def fill_menu
    @collection.alarms.each do |alarm|
      @status_menu.addItem create_alarm_item(alarm)
    end

    @status_menu.addItem NSMenuItem.separatorItem
    @status_menu.addItem create_menu_item('Add Alarm...', 'add_alarm')
    @status_menu.addItem create_menu_item('About Alarms', 'orderFrontStandardAboutPanel:')
    @status_menu.addItem create_menu_item('Quit', 'terminate:')
  end

  def create_menu_item(name, action)
    NSMenuItem.alloc.initWithTitle(name, action:action, keyEquivalent:'')
  end

  def create_alarm_item(alarm)
    item = NSMenuItem.alloc.initWithTitle(alarm_string(alarm), action:'edit_alarm:', keyEquivalent:'')
    item.setRepresentedObject(alarm)
    item
  end

  def alarm_string(alarm)
    alarm.to_menu_date + ' at ' + alarm.to_menu_time
  end
end
