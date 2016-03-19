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
    if !date.is_a?(NSDate)
      raise Exception.new('Invalid date in Alarm.initialize, must be an instance of NSDate')
    end

    @date = date
  end

  def self.unserialize(date_string)
    date = @@serialization_formatter.dateFromString(date_string)
    return nil unless date

    result = NSDate.date.compare(date)
    return nil if result != NSOrderedAscending

    Alarm.new(date)
  end

  def self.from_time(time_string)
    alarm = Time.at(NSDate.dateWithNaturalLanguageString(time_string))
    alarm += 24*60*60 if alarm < Time.at(NSDate.date)

    Alarm.new(alarm)
  end

  def serialize
    @@serialization_formatter.stringFromDate(@date)
  end

  def <=>(other)
    return 1 unless other.is_a?(Alarm)
    self.date <=> other.date
  end

  def to_menu_date # this is terrible and doesn't work on DST after 11pm when springing forward
    alarm_string = @@menu_date_formatter.stringFromDate(@date)
    today_string = @@menu_date_formatter.stringFromDate(NSDate.date)
    return 'Today' if alarm_string == today_string

    tomorrow = NSDate.date.dateByAddingTimeInterval(60*60*24)
    tomorrow_string = @@menu_date_formatter.stringFromDate(tomorrow)
    return 'Tomorrow' if alarm_string == tomorrow_string

    alarm_string
  end

  def to_menu_time
    @@menu_time_formatter.stringFromDate(@date)
  end

  def to_menu_string
    to_menu_date + ' at ' + to_menu_time
  end
end
