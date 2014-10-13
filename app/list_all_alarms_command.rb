class ListAllAlarmsCommand < NSScriptCommand
  def performDefaultImplementation
    alarms = AlarmCollection.unserialize_from_defaults.alarms
    alarms.map!.with_index { |alarm, index| "#{index}: #{alarm.to_menu_string}" }
    alarms.join("\n")
  end
end
