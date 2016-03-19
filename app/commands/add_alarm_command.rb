class AddAlarmCommand < ListAllAlarmsCommand
  def performDefaultImplementation
    alarm = Alarm.from_time(self.directParameter)
    return_string = super

    if !NSApplication.sharedApplication.delegate.alarm_added(alarm)
      return_string = "Unable to add alarm, too close to another.\n\n" + return_string
    end

    return_string
  end
end
