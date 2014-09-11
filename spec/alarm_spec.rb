describe Alarm do
  before do
    @nl_string = 'October 2nd 2100, 9:05am'
    @serialize_string = '210010020905'
  end

  it 'should throw an exception if the date is invalid on initialization' do
    invalid_date = 'abcd'
    lambda { Alarm.new(invalid_date) }.should.raise(Exception)
  end

  it 'should throw an exception if the date is in the past on initialization' do
    past_date = NSDate.date.dateByAddingTimeInterval(-600)
    lambda { Alarm.new(past_date) }.should.raise(Exception)
  end

  it 'should unserialize an alarm' do
    alarm = Alarm.unserialize(@serialize_string)
    alarm.date.should == NSDate.dateWithNaturalLanguageString(@nl_string)
  end

  it 'should return nil if it can\'t unserialize an alarm' do
    alarm = Alarm.unserialize('blah')
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
end
