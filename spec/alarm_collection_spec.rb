describe AlarmCollection do
  it 'should initialize an empty alarm list' do
    AlarmCollection.new([]).alarms.should == []
  end

  it 'should unserialize a list of alarms and skip blank lines' do
    alarms = "210010020545\n\n210011030646\n"
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
end
