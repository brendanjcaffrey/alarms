class Alarm
  attr_reader :date
  @@date_formatter = NSDateFormatter.alloc.init
  @@date_formatter.dateFormat = 'yyyyMMddHHmm'

  def initialize(date)
    unless date.is_a?(NSDate)
      raise Exception.new('Invalid date in Alarm.initialize, must be an instance of NSDate')
    end

    result = NSDate.date.compare(date)
    if result != NSOrderedAscending
      raise Exception.new('Invalid date in Alarm.initialize, must be in the future')
    end

    @date = date
  end

  def self.unserialize(date_string)
    date = @@date_formatter.dateFromString(date_string)

    return nil unless date
    Alarm.new(date)
  end

  def serialize
    @@date_formatter.stringFromDate(@date)
  end
end
