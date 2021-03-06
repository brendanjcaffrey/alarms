describe AlarmDriver do
  before do
    @delegate_mock = Object.new
    @action1_mock = Object.new
    @action2_mock = Object.new
    @action1_mock.mock!(:set_delegate)
    @action2_mock.mock!(:set_delegate)
    @driver = AlarmDriver.new(@delegate_mock, [@action1_mock, @action2_mock])
    @timer_method = 'scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:'
  end

  it 'should schedule two timers with the number of seconds to the alarm date' do
    @action1_mock.mock!(:finished) ; @action2_mock.mock!(:finished)
    alarm = Alarm.new(NSDate.date.dateByAddingTimeInterval(10000))

    NSTimer.mock!(@timer_method) do |int, _, _, _, _|
      if !@called_already
        @called_already = true
        int.should.be.close 10000.0, 0.1
      else
        int.should.be.close 10000.0 - 15*60, 0.1
      end
    end

    @driver.set_next_alarm(alarm)
  end

  it 'should invalidate the old timers' do
    @action1_mock.mock!(:finished) ; @action2_mock.mock!(:finished)
    alarm1 = Alarm.new(NSDate.date.dateByAddingTimeInterval(10000))
    alarm2 = Alarm.new(NSDate.date.dateByAddingTimeInterval(15000))
    timer_mock = mock(:invalidate)

    NSTimer.mock!(@timer_method) { |_, _, _, _, _| timer_mock }

    @driver.set_next_alarm(alarm1)
    @driver.set_next_alarm(alarm2)
  end

  it 'should invalidate the timer even if the nil is passed in instead of an alarm' do
    @action1_mock.mock!(:finished) ; @action2_mock.mock!(:finished)
    alarm0 = Alarm.new(NSDate.date.dateByAddingTimeInterval(10))
    timer_mock = mock(:invalidate)

    NSTimer.mock!(@timer_method) { |_, _, _, _, _| timer_mock }
    @driver.set_next_alarm(alarm0)
    @driver.set_next_alarm(nil)
  end

  it 'should call prestarted on all actions with the number of seconds until starting' do
    # finished gets called when we set the alarm
    @action1_mock.mock!(:finished) ; @action2_mock.mock!(:finished)
    alarm = Alarm.new(NSDate.date.dateByAddingTimeInterval(10))
    @driver.set_next_alarm(alarm)

    @action1_mock.mock!(:prestarted) { |time| time.should.be.close 10, 0.1 }
    @action2_mock.mock!(:prestarted) { |time| time.should.be.close 10, 0.1 }
    @driver.prestart_timer_fired(nil)
  end

  it 'should call started on all actions when the start timer fires' do
    @action1_mock.mock!(:started) ; @action2_mock.mock!(:started)
    @driver.start_timer_fired(nil)
  end

  it 'should call paused on all actions when an action calls pause on it' do
    @action1_mock.mock!(:paused) ; @action2_mock.mock!(:paused)
    @driver.pause
  end

  it 'should call unpaused on all actions when an action calls unpause on it' do
    @action1_mock.mock!(:unpaused) ; @action2_mock.mock!(:unpaused)
    @driver.unpause
  end

  it 'should call finished on all actions and tell the delegate the alarm was snoozed when an actions calls snooze on it' do
    @action1_mock.mock!(:finished) ; @action2_mock.mock!(:finished)
    @delegate_mock.mock!(:alarm_snoozed) { |alarm| alarm.should == @alarm }
    @driver.snooze
  end

  it 'should call finished on all actions and tell the delegate the alarm was deleted when an actions calls snooze on it' do
    @action1_mock.mock!(:finished) ; @action2_mock.mock!(:finished)
    @delegate_mock.mock!(:alarm_deleted) { |alarm| alarm.should == @alarm }
    @driver.stop
  end
end
