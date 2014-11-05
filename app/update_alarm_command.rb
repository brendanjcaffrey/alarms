class UpdateAlarmCommand < ListAllAlarmsCommand
  def performDefaultImplementation
    NSApplication.sharedApplication.delegate.alarm_edited_at_index(directParameter,
      Alarm.from_time(arguments['time']))

    super
  end
end
