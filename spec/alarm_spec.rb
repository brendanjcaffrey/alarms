describe Alarm do
  before do
    @nl_string = 'October 2nd 2100, 9:05am'
    @serialize_string = '210010020905'
  end

  it 'should throw an exception if the date is invalid on initialization' do
    invalid_date = 'abcd'
    lambda { Alarm.new(invalid_date) }.should.raise(Exception)
  end

  it 'should unserialize an alarm' do
    alarm = Alarm.unserialize(@serialize_string)
    alarm.date.should == NSDate.dateWithNaturalLanguageString(@nl_string)
  end

  it 'should return nil if it can\'t unserialize an alarm' do
    alarm = Alarm.unserialize('blah')
    alarm.should == nil
  end

  it 'should return nil if it can\'t unserialize an alarm because it\'s in the past' do
    alarm = Alarm.unserialize('200010101010')
    alarm.should == nil
  end

  it 'should serialize a date into the correct format' do
    alarm = Alarm.new(NSDate.dateWithNaturalLanguageString(@nl_string))
    alarm.serialize.should == @serialize_string
  end

  it 'should sort in ascending order' do
    alarm_past = Alarm.new(NSDate.date.dateByAddingTimeInterval(30))
    alarm_future = Alarm.new(NSDate.date.dateByAddingTimeInterval(60))

    alarm_past.<=>(alarm_future).should == -1
    alarm_past.<=>(alarm_past).should == 0
    alarm_future.<=>(alarm_past).should == 1
  end

  it 'should sort even if it\'s compared to something other than an NSDate' do
    alarm_past = Alarm.new(NSDate.date.dateByAddingTimeInterval(30))
    alarm_past.<=>(nil).should != 0
  end

  it 'should return Today or Tomorrow instead of the date if it is today or tomorrow' do
    Alarm.new(NSDate.date.dateByAddingTimeInterval(1)).to_menu_date.should == 'Today'
    Alarm.new(NSDate.date.dateByAddingTimeInterval(60*60*24)).to_menu_date.should == 'Tomorrow'
  end
end
