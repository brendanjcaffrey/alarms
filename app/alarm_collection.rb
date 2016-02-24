class AlarmCollection
  @@key = 'alarms'
  @@snooze_interval = 60.0*10.0 # seconds
  @@exclusivity_window_range = 60.0*15.0 # seconds

  attr_reader :alarms

  def initialize(alarms)
    @alarms = alarms
  end

  def self.unserialize(string)
    alarms = string.split("\n").reject { |str| str.empty? }
      .map { |str| Alarm.unserialize(str) }.reject { |alarm| alarm.nil? }
    AlarmCollection.new(alarms.sort)
  end

  def self.unserialize_from_defaults
    defaults = NSUserDefaults.standardUserDefaults
    defaults.setObject('', forKey:@@key) if defaults.objectForKey(@@key) == nil
    unserialize(defaults.objectForKey(@@key))
  end

  def serialize
    @alarms.map { |alarm| alarm.serialize }.join("\n")
  end

  def serialize_to_defaults
    NSUserDefaults.standardUserDefaults.setObject(serialize, forKey:@@key)
  end

  def first_alarm
    @alarms.first
  end

  def add_alarm(alarm)
    unless alarm.is_a?(Alarm)
      raise Exception.new('Alarm must be instance of Alarm in AlarmCollection.add_alarm')
    end

    # check to make sure there are no other alarms too close to this one
    start_date = alarm.date.dateByAddingTimeInterval(-1.0 * @@exclusivity_window_range)
    end_date = alarm.date.dateByAddingTimeInterval(@@exclusivity_window_range)
    return false if @alarms.any? { |a| a.date > start_date && a.date < end_date }

    @alarms << alarm
    @alarms.sort!
    true
  end

  def remove_alarm(alarm_to_delete)
    @alarms.reject! { |alarm| alarm == alarm_to_delete }
  end

  def remove_alarm_at_index(index)
    @alarms.delete_at(index) if index < @alarms.size
  end

  def update_alarm(alarm, new_date)
    remove_alarm(alarm)
    if add_alarm(Alarm.new(new_date))
      true
    else
      # if the new alarm got rejected, make sure to leave the old one in
      add_alarm(alarm)
      false
    end
  end

  def update_alarm_at_index(index, alarm)
    remove_alarm_at_index(index)
    add_alarm(alarm)
  end

  def snooze_alarm(alarm)
    update_alarm(alarm, alarm.date.dateByAddingTimeInterval(@@snooze_interval))
  end
end
