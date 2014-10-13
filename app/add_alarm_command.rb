class AddAlarmCommand < ListAllAlarmsCommand
  def performDefaultImplementation
    alarm = Alarm.from_time(self.directParameter)
    NSApplication.sharedApplication.delegate.alarm_added(alarm)
    super
  end
end
