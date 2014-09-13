describe AlarmCollection do
  it 'should initialize an empty alarm list' do
    AlarmCollection.new([]).alarms.should == []
  end

  it 'should unserialize a list of alarms, skip blank lines and sort ascending' do
    alarms = "210011030646\n\n210010020545\n"
    dates = [NSDate.dateWithNaturalLanguageString('October 2nd, 2100 5:45am'),
             NSDate.dateWithNaturalLanguageString('November 3rd, 2100 6:46am')]
    collection = AlarmCollection.unserialize(alarms)
    collection.alarms.count.should == 2
    collection.alarms[0].date.should == dates[0]
    collection.alarms[1].date.should == dates[1]
  end

  it 'should serialize an alarm list' do
    string = "210010020545\n210011030646"
    dates = [NSDate.dateWithNaturalLanguageString('October 2nd, 2100 5:45am'),
             NSDate.dateWithNaturalLanguageString('November 3rd, 2100 6:46am')]
    alarms = dates.map { |date| Alarm.new(date) }

    AlarmCollection.new(alarms).serialize.should == string
  end

  it 'should insert alarms in sorted order' do
    alarm0 = Alarm.new(NSDate.date.dateByAddingTimeInterval(15))
    alarm1 = Alarm.new(NSDate.date.dateByAddingTimeInterval(30))
    alarm2 = Alarm.new(NSDate.date.dateByAddingTimeInterval(45))
    collection = AlarmCollection.new([alarm1])

    collection.add_alarm(alarm2)
    collection.alarms[1].should == alarm2

    collection.add_alarm(alarm0)
    collection.alarms[0].should == alarm0
  end

  it 'should throw an exception if you try to insert something other than an Alarm' do
    lambda { AlarmCollection.new([]).add_alarm('abcd') }.should.raise(Exception)
  end

  it 'should delete alarms' do
    alarm0 = Alarm.new(NSDate.date.dateByAddingTimeInterval(15))
    alarm1 = Alarm.new(NSDate.date.dateByAddingTimeInterval(30))
    alarm2 = Alarm.new(NSDate.date.dateByAddingTimeInterval(45))
    collection = AlarmCollection.new([alarm0, alarm1, alarm2])

    collection.remove_alarm(alarm1)
    collection.alarms[0].should == alarm0
    collection.alarms[1].should == alarm2
  end

  it 'should update alarms' do
    alarm0 = Alarm.new(NSDate.date.dateByAddingTimeInterval(15))
    new_date = NSDate.date.dateByAddingTimeInterval(30)

    collection = AlarmCollection.new([alarm0])
    collection.update_alarm(alarm0, new_date)
    collection.alarms[0].date.should == new_date
  end
end
