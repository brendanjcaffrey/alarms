class Date
  attr_reader :date

  def initialize(year, month, day)
    comps = NSDateComponents.alloc.init
    comps.setYear(year)
    comps.setMonth(month)
    comps.setDay(day)

    gregorian = NSCalendar.alloc.initWithCalendarIdentifier(NSGregorianCalendar)
    @date = gregorian.dateFromComponents(comps)
  end

  def self.today
    now = NSDate.date
    Date.new(now.year, now.month, now.day)
  end

  def self.tomorrow
    now = NSDate.date
    # Foundation takes care of wrapping around months and years
    Date.new(now.year, now.month, now.day + 1)
  end

  def is_same_day_as(date)
    date.year == @date.year && date.month == @date.month && date.day == @date.day
  end
end
