class Alarm
  include Comparable
  attr_reader :date

  @@serialization_formatter = NSDateFormatter.alloc.init
  @@serialization_formatter.dateFormat = 'yyyyMMddHHmm'

  @@menu_date_formatter = NSDateFormatter.alloc.init
  @@menu_date_formatter.dateFormat = 'MM/dd/yy'

  @@menu_time_formatter = NSDateFormatter.alloc.init
  @@menu_time_formatter.dateFormat = 'h:mm a'

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
    date = @@serialization_formatter.dateFromString(date_string)

    return nil unless date
    Alarm.new(date)
  end

  def serialize
    @@serialization_formatter.stringFromDate(@date)
  end

  def <=>(other)
    self.date <=> other.date
  end

  def to_menu_date
    alarm_string = @@menu_date_formatter.stringFromDate(@date)
    today_string = @@menu_date_formatter.stringFromDate(NSDate.date)
    return 'Today' if alarm_string == today_string

    tomorrow_string = @@menu_date_formatter.stringFromDate(NSDate.date.dateByAddingTimeInterval(60*60*24))
    return 'Tomorrow' if alarm_string == tomorrow_string
    alarm_string
  end

  def to_menu_time
    @@menu_time_formatter.stringFromDate(@date)
  end

end
