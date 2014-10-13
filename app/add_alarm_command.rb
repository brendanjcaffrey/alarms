class AddAlarmCommand < NSScriptCommand
  def performDefaultImplementation
    alarm = Alarm.from_time(self.directParameter)
    NSApplication.sharedApplication.delegate.alarm_added(alarm)
    "Alarm added for: #{alarm.to_menu_string}"
  end
end
