describe AlarmSounder do
  it 'should schedule a timer with the number of seconds to the alarm date' do
    alarm = Alarm.new(NSDate.date.dateByAddingTimeInterval(10))
    NSTimer.mock!('scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:') do |int, tar, sel, ui, r|
      int.should.be.close 10.0, 0.1
    end
    AlarmSounder.new(self).set_next_alarm(alarm)
  end

  it 'should invalidate the old timer' do
    alarm1 = Alarm.new(NSDate.date.dateByAddingTimeInterval(10))
    alarm2 = Alarm.new(NSDate.date.dateByAddingTimeInterval(15))
    timer_mock = mock(:invalidate)

    NSTimer.mock!('scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:') do |int, tar, sel, ui, r|
      timer_mock
    end

    sounder = AlarmSounder.new(self)
    sounder.set_next_alarm(alarm1)
    sounder.set_next_alarm(alarm2)
  end

  it 'should delegate an alarm deletion when the timer fires' do
    @alarm = Alarm.new(NSDate.date.dateByAddingTimeInterval(5))

    delegate = mock(:alarm_deleted) do |alarm|
      alarm.should == @alarm
    end

    sounder = AlarmSounder.new(delegate)
    sounder.instance_variable_set(:@alarm, @alarm)
    sounder.fired(nil)
  end
end
