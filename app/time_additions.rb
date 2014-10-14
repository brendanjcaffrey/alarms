class Time
  @@tomorrow_offset = NSDateComponents.alloc.init.tap { |o| o.day = 1 }

  def self.tomorrow
    Time.at(NSCalendar.currentCalendar.dateByAddingComponents(@@tomorrow_offset,
                                                              toDate:NSDate.date, options:0))
  end

  def same_day?(other)
    year == other.year && month == other.month && day == other.day
  end

  def hour_and_minute_less_than?(other)
    hour < other.hour || (hour == other.hour && min < other.min)
  end
end
