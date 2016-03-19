class UpdateAlarmCommand < ListAllAlarmsCommand
  def performDefaultImplementation
    return_string = super
    new_alarm = Alarm.from_time(arguments['time'])
    delegate = NSApplication.sharedApplication.delegate

    if !delegate.alarm_edited_at_index(directParameter, new_alarm)
      return_string = "Unable to update alarm, too close to another.\n\n" + return_string
    end

    return_string
  end
end
