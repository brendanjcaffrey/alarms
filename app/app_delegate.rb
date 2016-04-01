class AppDelegate
  attr_accessor :status_menu

  def applicationDidFinishLaunching(notification)
    return true if RUBYMOTION_ENV == 'test'

    @driver = AlarmDriver.new(self, Action.actions.map(&:new))
    @collection = AlarmCollection.unserialize_from_defaults

    NSNotificationCenter.defaultCenter.addObserverForName(NSSystemTimeZoneDidChangeNotification,
      object: nil, queue: nil, usingBlock: proc { |notif| self.time_zone_changed })

    build_menu
    alarms_changed
    set_midnight_timer
  end

  def time_zone_changed
    # just unserialize again to get in the right timezone
    # NOTE: this will drop alarms that are in the past in the new timezone
    @collection = AlarmCollection.unserialize_from_defaults
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
    return false unless @collection.add_alarm(arg)
    alarms_changed
    true
  end

  def alarm_edited(old_alarm, new_date)
    return false unless @collection.update_alarm(old_alarm, new_date)
    alarms_changed
    true
  end

  def alarm_edited_at_index(index, new_alarm)
    return false unless @collection.update_alarm_at_index(index, new_alarm)
    alarms_changed
    true
  end

  def alarm_deleted(alarm)
    @collection.remove_alarm(alarm)
    alarms_changed
  end

  def alarm_deleted_at_index(index)
    @collection.remove_alarm_at_index(index)
    alarms_changed
  end

  def alarm_snoozed(alarm)
    @collection.snooze_alarm(alarm)
    alarms_changed
  end

  def midnight_timer_fired(sender)
    reset_menu
    set_midnight_timer
  end

  private

  def set_midnight_timer
    @midnight_timer.invalidate if @midnight_timer

    now = Time.at(NSDate.date)
    seconds_until_midnight = (23-now.hour)*3600 + (59-now.min)*60 + (60-now.sec)
    @midnight_timer = NSTimer.scheduledTimerWithTimeInterval(seconds_until_midnight,
      target: self, selector: 'midnight_timer_fired:', userInfo: nil, repeats: false)
  end

  def show_alarm_window(alarm)
    @window = AlarmInfoController.alloc.init_with_alarm(alarm, delegate: self)
    @window.window.center
    @window.showWindow(nil)
    NSApplication.sharedApplication.activateIgnoringOtherApps(true)
  end

  def build_menu
    @status_menu = NSMenu.new

    @status_item = NSStatusBar.systemStatusBar.statusItemWithLength(NSVariableStatusItemLength).init
    @status_item.setMenu(@status_menu)
    @status_item.button.setImage(NSImage.imageNamed('alarm').tap { |i| i.setTemplate(true) })
  end

  def fill_menu
    @collection.alarms.each do |alarm|
      @status_menu.addItem(create_alarm_item(alarm))
    end

    @status_menu.addItem(NSMenuItem.separatorItem) if @collection.first_alarm != nil
    @status_menu.addItem(create_menu_item('Add Alarm...', 'add_alarm'))
    @status_menu.addItem(create_menu_item('About Alarms', 'orderFrontStandardAboutPanel:'))
    @status_menu.addItem(create_menu_item('Quit', 'terminate:'))
  end

  def alarms_changed
    @status_item.button.looksDisabled = @collection.first_alarm.nil?
    @driver.set_next_alarm(@collection.first_alarm)
    @collection.serialize_to_defaults
    reset_menu
  end

  def reset_menu
    @status_menu.removeAllItems
    fill_menu
  end

  def create_menu_item(name, action)
    NSMenuItem.alloc.initWithTitle(name, action: action, keyEquivalent: '')
  end

  def create_alarm_item(alarm)
    item = NSMenuItem.alloc.initWithTitle(alarm_string(alarm), action: 'edit_alarm:', keyEquivalent: '')
    item.setRepresentedObject(alarm)
    item
  end

  def alarm_string(alarm)
    alarm.to_menu_date + ' at ' + alarm.to_menu_time
  end
end
