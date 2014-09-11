class AlarmCollection
  attr_reader :alarms

  def initialize(alarms)
    @alarms = alarms
  end

  def self.unserialize(string)
    alarms = string.split("\n").reject { |str| str.empty? }
      .map { |str| Alarm.unserialize(str) }
    AlarmCollection.new(alarms)
  end

  def serialize
    @alarms.map { |alarm| alarm.serialize }.join("\n")
  end
end
