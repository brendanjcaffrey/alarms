class AlarmCollection
  ALARMS_KEY         = 'alarms'
  SNOOZE_TIME        = 60.0*10.0 # seconds
  EXCLUSIVITY_WINDOW = 60.0*5.0  # seconds

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
    defaults.setObject('', forKey: ALARMS_KEY) if defaults.objectForKey(ALARMS_KEY) == nil
    unserialize(defaults.objectForKey(ALARMS_KEY))
  end

  def serialize
    @alarms.map { |alarm| alarm.serialize }.join("\n")
  end

  def serialize_to_defaults
    NSUserDefaults.standardUserDefaults.setObject(serialize, forKey: ALARMS_KEY)
  end

  def first_alarm
    @alarms.first
  end

  def add_alarm(alarm)
    unless alarm.is_a?(Alarm)
      raise Exception.new('Alarm must be instance of Alarm in AlarmCollection.add_alarm')
    end

    # check to make sure there are no other alarms too close to this one
    start_date = alarm.date.dateByAddingTimeInterval(-1.0 * EXCLUSIVITY_WINDOW)
    end_date = alarm.date.dateByAddingTimeInterval(EXCLUSIVITY_WINDOW)
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
    remove_alarm(alarm)

    # NOTE add_alarm can fail here if there's another alarm too close, but that's fine
    add_alarm(Alarm.new(alarm.date.dateByAddingTimeInterval(SNOOZE_TIME)))
  end
end
