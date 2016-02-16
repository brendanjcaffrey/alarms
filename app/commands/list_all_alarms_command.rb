class ListAllAlarmsCommand < NSScriptCommand
  def performDefaultImplementation
    alarms = AlarmCollection.unserialize_from_defaults.alarms
    alarms.map!.with_index { |alarm, index| "#{index}: #{alarm.to_menu_string}" }
    return 'No alarms currently set' if alarms.empty?
    alarms.join("\n")
  end
end
