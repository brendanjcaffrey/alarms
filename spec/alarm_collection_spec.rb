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

  it 'should ignore past alarms when unserializing' do
    alarm = '200011030646'
    collection = AlarmCollection.unserialize(alarm)
    collection.alarms.count.should == 0
  end

  it 'should serialize an alarm list' do
    string = "210010020545\n210011030646"
    dates = [NSDate.dateWithNaturalLanguageString('October 2nd, 2100 5:45am'),
             NSDate.dateWithNaturalLanguageString('November 3rd, 2100 6:46am')]
    alarms = dates.map { |date| Alarm.new(date) }

    AlarmCollection.new(alarms).serialize.should == string
  end

  it 'should return the first alarm by time' do
    alarm0 = Alarm.new(NSDate.date.dateByAddingTimeInterval(15))
    collection = AlarmCollection.new([alarm0])
    collection.first_alarm.should == alarm0
  end

  it 'should return nil if there is no first alarm' do
    AlarmCollection.new([]).first_alarm.should == nil
  end

  it 'should insert alarms in sorted order' do
    alarm0 = Alarm.new(NSDate.date.dateByAddingTimeInterval(15))
    alarm1 = Alarm.new(NSDate.date.dateByAddingTimeInterval(30000))
    alarm2 = Alarm.new(NSDate.date.dateByAddingTimeInterval(45000))
    collection = AlarmCollection.new([alarm1])

    collection.add_alarm(alarm2).should == true
    collection.alarms[1].should == alarm2

    collection.add_alarm(alarm0).should == true
    collection.alarms[0].should == alarm0
  end

  it 'should not let you insert alarms at the same time or near each other' do
    alarm0 = Alarm.new(NSDate.date.dateByAddingTimeInterval(15))
    alarm1 = Alarm.new(NSDate.date.dateByAddingTimeInterval(15))
    alarm2 = Alarm.new(NSDate.date.dateByAddingTimeInterval(15 + 60))
    collection = AlarmCollection.new([alarm0])
    collection.add_alarm(alarm1).should == false
    collection.alarms.count == 1
    collection.add_alarm(alarm2).should == false
    collection.alarms.count == 1
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

  it 'should delete alarms at specified indices' do
    alarm0 = Alarm.new(NSDate.date.dateByAddingTimeInterval(15))
    alarm1 = Alarm.new(NSDate.date.dateByAddingTimeInterval(30))
    alarm2 = Alarm.new(NSDate.date.dateByAddingTimeInterval(45))
    collection = AlarmCollection.new([alarm0, alarm1, alarm2])

    collection.remove_alarm_at_index(1).should == alarm1
    collection.alarms[0].should == alarm0
    collection.alarms[1].should == alarm2

    collection.remove_alarm_at_index(0).should == alarm0
    collection.alarms[0].should == alarm2

    collection.remove_alarm_at_index(100).should == nil
    collection.alarms[0].should == alarm2
  end

  it 'should update alarms' do
    alarm0 = Alarm.new(NSDate.date.dateByAddingTimeInterval(15))
    new_date = NSDate.date.dateByAddingTimeInterval(30)

    collection = AlarmCollection.new([alarm0])
    collection.update_alarm(alarm0, new_date).should == true
    collection.alarms[0].date.should == new_date
  end

  it 'should not maintain the original alarm if it can\'t update it' do
    orig_date = NSDate.date.dateByAddingTimeInterval(15)
    new_date = NSDate.date.dateByAddingTimeInterval(30000)
    alarm0 = Alarm.new(orig_date)
    alarm1 = Alarm.new(new_date)

    collection = AlarmCollection.new([alarm0, alarm1])
    collection.update_alarm(alarm0, new_date).should == false
    collection.alarms[0].date.should == orig_date
    collection.alarms[1].date.should == new_date
  end

  it 'should update alarms at indices' do
    alarm0 = Alarm.new(NSDate.date.dateByAddingTimeInterval(15))
    alarm1 = Alarm.new(NSDate.date.dateByAddingTimeInterval(30))

    collection = AlarmCollection.new([alarm0])
    collection.update_alarm_at_index(0, alarm1)
    collection.alarms[0].should == alarm1
  end

  it 'should snooze alarms' do
    alarm = Alarm.new(NSDate.date.dateByAddingTimeInterval(15))
    interval = AlarmCollection.class_variable_get(:@@snooze_interval)
    new_date = alarm.date.dateByAddingTimeInterval(interval)

    collection = AlarmCollection.new([alarm])
    collection.snooze_alarm(alarm)
    collection.alarms[0].date.should == new_date
  end
end
