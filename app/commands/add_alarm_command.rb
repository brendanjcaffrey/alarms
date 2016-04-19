class AddAlarmCommand < ListAllAlarmsCommand
  ERROR_MSG = "Unable to add alarm, too close to another.\n\n"

  def performDefaultImplementation
    alarm = Alarm.from_time(self.directParameter)
    delegate = NSApplication.sharedApplication.delegate

    (delegate.alarm_added(alarm) ? "" : ERROR_MSG) + super
  end
end
