class AlarmCollection
  @@snooze_interval = 60.0*5.0
  attr_reader :alarms

  def initialize(alarms)
    @alarms = alarms
  end

  def self.unserialize(string)
    alarms = string.split("\n").reject { |str| str.empty? }
      .map { |str| Alarm.unserialize(str) }.reject { |alarm| alarm.nil? }
    AlarmCollection.new(alarms.sort)
  end

  def serialize
    @alarms.map { |alarm| alarm.serialize }.join("\n")
  end

  def add_alarm(alarm)
    unless alarm.is_a?(Alarm)
      raise Exception.new('Alarm must be instance of Alarm in AlarmCollection.add_alarm')
    end

    @alarms << alarm
    @alarms.sort!
  end

  def remove_alarm(alarm_to_delete)
    @alarms.reject! { |alarm| alarm == alarm_to_delete }
  end

  def update_alarm(alarm, new_date)
    remove_alarm(alarm)
    add_alarm(Alarm.new(new_date))
  end

  def snooze_alarm(alarm)
    update_alarm(alarm, alarm.date.dateByAddingTimeInterval(@@snooze_interval))
  end
end
