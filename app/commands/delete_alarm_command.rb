class DeleteAlarmCommand < ListAllAlarmsCommand
  def performDefaultImplementation
    NSApplication.sharedApplication.delegate.alarm_deleted_at_index(self.directParameter)
    super
  end
end
