class UpdateAlarmCommand < ListAllAlarmsCommand
  ERROR_MSG = "Unable to update alarm, too close to another.\n\n"

  def performDefaultImplementation
    index = directParameter
    alarm = Alarm.from_time(arguments['time'])
    delegate = NSApplication.sharedApplication.delegate

    (delegate.alarm_edited_at_index(index, alarm) ? "" : ERROR_MSG) + super
  end
end
