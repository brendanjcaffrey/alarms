class AlarmCollection
  attr_reader :alarms

  def initialize(alarms)
    @alarms = alarms
  end

  def self.unserialize(string)
    alarms = string.split("\n").reject { |str| str.empty? }
      .map { |str| Alarm.unserialize(str) }
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
end
