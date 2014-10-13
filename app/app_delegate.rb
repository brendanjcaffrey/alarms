class AppDelegate
  attr_accessor :status_menu

  def applicationDidFinishLaunching(notification)
    @sounder = AlarmSounder.new(self, AudioPlayer.new, LeapMotionTalker.new, ControlPanelShower.new, LightsController.new)
    @collection = AlarmCollection.unserialize_from_defaults

    build_menu
    alarms_changed
  end

  def add_alarm
    show_alarm_window(nil)
  end

  def edit_alarm(menu_item)
    show_alarm_window(menu_item.representedObject)
  end

  def alarm_added(arg)
    arg = Alarm.new(arg) if arg.is_a?(NSDate)
    @collection.add_alarm(arg)
    alarms_changed
  end

  def alarm_edited(old_alarm, new_date)
    @collection.update_alarm(old_alarm, new_date)
    alarms_changed
  end

  def alarm_deleted(alarm)
    @collection.remove_alarm(alarm)
    alarms_changed
  end

  def alarm_snoozed(alarm)
    @collection.snooze_alarm(alarm)
    alarms_changed
  end

  private

  def show_alarm_window(alarm)
    @window = AlarmInfoController.alloc.init_with_alarm(alarm, delegate:self)
    @window.window.center
    @window.showWindow(nil)
    NSApplication.sharedApplication.activateIgnoringOtherApps(true)
  end

  def build_menu
    @status_menu = NSMenu.new

    @status_item = NSStatusBar.systemStatusBar.statusItemWithLength(NSVariableStatusItemLength).init
    @status_item.setMenu(@status_menu)
    @status_item.setHighlightMode(true)
    @status_item.setImage(NSImage.imageNamed('alarm'))
  end

  def fill_menu
    @collection.alarms.each do |alarm|
      @status_menu.addItem create_alarm_item(alarm)
    end

    @status_menu.addItem NSMenuItem.separatorItem if @collection.first_alarm != nil
    @status_menu.addItem create_menu_item('Add Alarm...', 'add_alarm')
    @status_menu.addItem create_menu_item('About Alarms', 'orderFrontStandardAboutPanel:')
    @status_menu.addItem create_menu_item('Quit', 'terminate:')
  end

  def alarms_changed
    @sounder.set_next_alarm(@collection.first_alarm)
    @collection.serialize_to_defaults
    reset_menu
  end

  def reset_menu
    @status_menu.removeAllItems
    fill_menu
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
